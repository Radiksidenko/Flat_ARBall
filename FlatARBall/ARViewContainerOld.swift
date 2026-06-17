//
//  ARViewContainerOld.swift
//  FlatARBall
//
//  Created by Radomyr Sidenko on 17.06.2026.
//

import SwiftUI
import ARKit
import SceneKit

struct ARViewContainerOld: UIViewRepresentable {
    
    @Binding var shouldTakeSnapshot: Bool
    var onSnapshotTaken: (UIImage) -> Void

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.showsStatistics = false
        
        context.coordinator.setupScene(for: sceneView)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if shouldTakeSnapshot {
            DispatchQueue.main.async {
                let image = uiView.snapshot()
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self.onSnapshotTaken(image)
                self.shouldTakeSnapshot = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        func setupScene(for sceneView: ARSCNView) {
            let line = SCNBox(width: 0.05, height: 0.01, length: 0.01, chamferRadius: 0)
            let line2 = SCNBox(width: 0.09, height: 0.01, length: 0.01, chamferRadius: 0)
            let line3 = SCNBox(width: 0.11, height: 0.02, length: 0.01, chamferRadius: 0)
            let line4 = SCNBox(width: 0.1, height: 0.01, length: 0.01, chamferRadius: 0)
            let line5 = SCNBox(width: 0.07, height: 0.01, length: 0.01, chamferRadius: 0)
            let line6 = SCNBox(width: 0.04, height: 0.01, length: 0.01, chamferRadius: 0)
            
            [line, line2, line3, line4, line5, line6].forEach {
                $0.firstMaterial?.diffuse.contents = UIColor.yellow
            }
            
            let nodes = [
                SCNNode(geometry: line), SCNNode(geometry: line2), SCNNode(geometry: line3),
                SCNNode(geometry: line4), SCNNode(geometry: line5), SCNNode(geometry: line6),
                SCNNode(geometry: line5), SCNNode(geometry: line4), SCNNode(geometry: line3),
                SCNNode(geometry: line2), SCNNode(geometry: line)
            ]
            
            let positions: [SCNVector3] = [
                SCNVector3(0, 0, 0),        SCNVector3(0, -0.01, 0),   SCNVector3(0, -0.025, 0),
                SCNVector3(0.015, -0.04, 0), SCNVector3(0.03, -0.05, 0), SCNVector3(0.045, -0.06, 0),
                SCNVector3(0.03, -0.07, 0),  SCNVector3(0.015, -0.08, 0), SCNVector3(0, -0.095, 0),
                SCNVector3(0, -0.11, 0),     SCNVector3(0, -0.12, 0)
            ]
            
            let scene = SCNScene()
            for (index, node) in nodes.enumerated() {
                node.position = positions[index]
                scene.rootNode.addChildNode(node)
            }
            
            sceneView.scene = scene
        }
    }
    
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause()
    }
}

struct ARViewControllerOld: View {
    @State private var takeSnapshot = false
    @State private var lastCapturedImage: UIImage? = nil

    var body: some View {
        ZStack {
            ARViewContainerOld(shouldTakeSnapshot: $takeSnapshot) { capturedImage in
                self.lastCapturedImage = capturedImage
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    if let image = lastCapturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 90)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 5)
                            .transition(.scale)
                    } else {
                        Spacer().frame(width: 70)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        takeSnapshot = true
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.2), lineWidth: 4)
                                    .frame(width: 60, height: 60)
                            )
                            .shadow(radius: 10)
                    }
                    
                    Spacer()
                    
                    Spacer().frame(width: 70)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}
