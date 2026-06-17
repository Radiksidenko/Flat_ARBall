//
//  ARViewController.swift
//  FlatARBall
//
//  Created by Radomyr Sidenko on 16.06.2026.
//

import UIKit
import RealityKit
import ARKit
import Combine

final class ARViewController: UIViewController {

    private var arView: ARView!
    private var cancellables = Set<AnyCancellable>()
    private var sphereEntity: ModelEntity?
    private let shaderStartTime: CFTimeInterval = CACurrentMediaTime()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupARView()
        setupSession()
        setupScene()
        setupGestures()
        setupShaderTimeUpdate()
    }

    private func setupARView() {
        arView = ARView(frame: view.bounds, cameraMode: .ar,
                        automaticallyConfigureSession: false)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(arView)
        arView.environment.sceneUnderstanding.options = [.physics, .collision, .occlusion]
        arView.renderOptions = [.disableMotionBlur]
    }

    private func setupSession() {
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        config.planeDetection = [.horizontal, .vertical]
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arView.session.delegate = self
    }

    private func setupScene() {
        let floorAnchor  = AnchorEntity(plane: .horizontal)
        let floorMesh    = MeshResource.generatePlane(width: 10, depth: 10)
        let floorEntity  = ModelEntity(mesh: floorMesh, materials: [OcclusionMaterial()])
        floorEntity.components.set(
            CollisionComponent(shapes: [.generateBox(width: 10, height: 0.001, depth: 10)])
        )
        floorEntity.components.set(
            PhysicsBodyComponent(
                massProperties: .default,
                material: .generate(staticFriction: 0.4, dynamicFriction: 0.3, restitution: 0.6),
                mode: .static
            )
        )
        floorAnchor.addChild(floorEntity)
        arView.scene.addAnchor(floorAnchor)
    }

    private func setupShaderTimeUpdate() {
        arView.scene.subscribe(to: SceneEvents.Update.self, on: nil) { [weak self] _ in
            guard let self, let sphere = self.sphereEntity else { return }
            ShaderMaterialManager.shared.updateTime(on: sphere,
                                                    startTime: self.shaderStartTime)
        }.store(in: &cancellables)
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tap)
    }

    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: arView)
        guard let result = arView.raycast(from: location,
                                          allowing: .estimatedPlane,
                                          alignment: .any).first else { return }
        spawnSphere(at: result.worldTransform)
    }

    private func spawnSphere(at transform: simd_float4x4) {
        let radius: Float = 0.06
        let mesh = MeshResource.generateSphere(radius: radius)

        let material: any RealityKit.Material
        if let glass = ShaderMaterialManager.shared.makeGlassMaterial() {
            material = glass
        } else {
            var pbr = PhysicallyBasedMaterial()
            pbr.baseColor = .init(tint: UIColor(white: 1, alpha: 0.3))
            pbr.roughness  = .init(floatLiteral: 0.05)
            pbr.blending   = .transparent(opacity: .init(floatLiteral: 0.35))
            material = pbr
        }

        let sphere = ModelEntity(mesh: mesh, materials: [material])
        sphere.components.set(
            CollisionComponent(shapes: [.generateSphere(radius: radius)])
        )
        sphere.components.set(
            PhysicsBodyComponent(
                massProperties: PhysicsMassProperties(
                    shape: .generateSphere(radius: radius), mass: 2.5),
                material: .generate(staticFriction: 0.15,
                                    dynamicFriction: 0.10,
                                    restitution: 0.72),
                mode: .dynamic
            )
        )

        var spawnTransform = transform
        spawnTransform.columns.3.y += 0.25
        let anchor = AnchorEntity(world: spawnTransform)
        anchor.addChild(sphere)
        arView.scene.addAnchor(anchor)
        sphereEntity = sphere
    }
}

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("ARSession error: \(error.localizedDescription)")
    }
}
