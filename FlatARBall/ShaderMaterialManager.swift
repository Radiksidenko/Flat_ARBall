//
//  ShaderMaterialManager.swift
//  FlatARBall
//
//  Created by Radomyr Sidenko on 16.06.2026.
//

import RealityKit
import Metal
import QuartzCore

final class ShaderMaterialManager {

    static let shared = ShaderMaterialManager()
    private init() {}

    func makeGlassMaterial() -> CustomMaterial? {
        guard let device = MTLCreateSystemDefaultDevice(),
              let library = device.makeDefaultLibrary() else {
            print("[ShaderMaterialManager] MTLLibrary недоступна.")
            return nil
        }

        let surfaceShader = CustomMaterial.SurfaceShader(
            named: "glassSphereShader",
            in: library
        )

        var basePBR = PhysicallyBasedMaterial()
        basePBR.baseColor = .init(tint: .white)
        basePBR.roughness = .init(floatLiteral: 0.05)
        basePBR.metallic  = .init(floatLiteral: 0.0)
        basePBR.clearcoat = .init(floatLiteral: 1.0)

        do {
            var custom = try CustomMaterial(from: basePBR, surfaceShader: surfaceShader)
            custom.custom.value = SIMD4<Float>(0.10, 0.05, 0.50, 0.0)
            return custom
        } catch {
            print("[ShaderMaterialManager] CustomMaterial init failed: \(error)")
            return nil
        }
    }

    func updateTime(on entity: ModelEntity, startTime: CFTimeInterval) {
        guard var mat = entity.model?.materials.first as? CustomMaterial else { return }
        let elapsed = Float(CACurrentMediaTime() - startTime)
        mat.custom.value.w = elapsed
        entity.model?.materials = [mat]
    }
}
