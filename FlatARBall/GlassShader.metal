//
//  GlassShader.metal
//  FlatARBall
//
//  Created by Radomyr Sidenko on 16.06.2026.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

float2 hash2(float2 p) {
    p = float2(dot(p, float2(127.1, 311.7)),
               dot(p, float2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

float voronoi(float2 x) {
    float2 n = floor(x);
    float2 f = fract(x);
    float minDist = 1.0;
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            float2 g = float2(float(i), float(j));
            float2 o = hash2(n + g);
            float2 r = g - f + o;
            float  d = dot(r, r);
            if (d < minDist) minDist = d;
        }
    }
    return minDist;
}

float3 rotate3D(float3 p, float time) {
    float sY = sin(time * 0.5), cY = cos(time * 0.5);
    float3 p1 = float3(p.x * cY + p.z * sY, p.y, -p.x * sY + p.z * cY);
    float sX = sin(time * 0.2), cX = cos(time * 0.2);
    return float3(p1.x, p1.y * cX - p1.z * sX, p1.y * sX + p1.z * cX);
}

[[visible]]
void glassSphereShader(realitykit::surface_parameters params) {

    float3 N    = normalize(params.geometry().normal());
    float3 V    = normalize(params.geometry().view_direction());
    float2 uv   = params.geometry().uv0();

    float2 diskUV = uv * 2.0 - 1.0;
    float  len    = length(diskUV);
    float  NdotV  = saturate(dot(N, V));

    float4 cp          = params.uniforms().custom_parameter();
    float  baseAlpha   = cp.x;
    float  crackThresh = cp.y;
    float  iorStrength = cp.z;
    float  time        = cp.w;

    float3 rotatedNormal = rotate3D(N, time);

    float2 crackUV = rotatedNormal.xy * 5.0;
    float  noise1  = voronoi(crackUV);
    float  noise2  = voronoi(crackUV + float2(0.1));
    float  crackLine = abs(noise1 - noise2);
    float  isCrack   = step(crackLine, crackThresh) * step(0.4, noise1);

    float rings = sin(length(rotatedNormal.xy) * 40.0) * 0.15;
    float3 distortedN = normalize(float3(N.x, N.y,
                                         N.z + rings * (1.0 - len) - (isCrack * 0.5)));

    float fresnel = pow(1.0 - NdotV, 3.0);

    float aberration = 0.08 + (isCrack * 0.1);
    float3 aberColor = float3(
        sin(fresnel * 3.14 + 0.0)              * aberration * 4.0,
        sin(fresnel * 3.14 + 2.09)             * aberration * 4.0,
        sin(fresnel * 3.14 + 4.18)             * aberration * 4.0
    );
    aberColor = saturate(aberColor);

    float3 glassBase  = float3(0.88, 0.93, 1.0);
    float3 finalColor = mix(glassBase, aberColor, fresnel * 0.6);

    finalColor += float3(isCrack * 0.4);

    float edgeShadow = smoothstep(0.8, 1.0, len);
    finalColor = saturate(finalColor - float3(edgeShadow * 0.3));

    float ior  = iorStrength + (isCrack * 0.3);
    float rough = clamp(0.04 + ior * 0.05 * (1.0 - fresnel), 0.02, 0.15);

    float alpha = mix(baseAlpha, 0.75, fresnel) + isCrack * 0.15;
    alpha = saturate(alpha);

    params.surface().set_base_color(half3(finalColor));
    params.surface().set_opacity(half(alpha));
    params.surface().set_roughness(half(rough));
    params.surface().set_metallic(half(0.0));

    half3 emissive = half3(aberColor * fresnel * 0.35 + float3(isCrack * 0.2));
    params.surface().set_emissive_color(emissive);
}
