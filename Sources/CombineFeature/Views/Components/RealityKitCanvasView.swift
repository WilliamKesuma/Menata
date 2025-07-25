//
//  RealityKitCanvasView.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import SwiftUI
import RealityKit
import ARKit

struct RealityKitCanvasView: UIViewRepresentable {
    @Binding var placedObjects: [Entity]
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        
        // Setup scene
        setupScene(arView, coordinator: context.coordinator)
        
        // Setup gesture recognizers
        GestureManager.setupGestureRecognizers(arView, coordinator: context.coordinator)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Add new objects to scene
        for object in placedObjects {
            if object.parent == nil {
                // Position new object at center initially
                object.position = SIMD3<Float>(0, 0.1, 0)
                uiView.scene.addAnchor(createAnchorEntity(with: object))
                
                // Store reference to coordinator for later access
                context.coordinator.allObjects.append(object)
            }
        }
    }
    
    func makeCoordinator() -> CanvasCoordinator {
        CanvasCoordinator(self)
    }
    
    private func setupScene(_ arView: ARView, coordinator: CanvasCoordinator) {
        // Create infinite grid floors
        GridManager.createInfiniteGridFloor(arView, coordinator: coordinator)
        
        // Setup lighting
        setupLighting(arView)
        
        // Setup camera position
        CameraManager.setupCamera(arView, coordinator: coordinator)
        
        // Set gray background
        arView.environment.background = .color(.systemGray5)
    }
    
    private func setupLighting(_ arView: ARView) {
        // Add directional light
        let directionalLight = DirectionalLight()
        directionalLight.light.intensity = 2000
        directionalLight.orientation = simd_quatf(angle: -.pi/4, axis: [1, 1, 0])
        
        let lightAnchor = AnchorEntity()
        lightAnchor.addChild(directionalLight)
        arView.scene.addAnchor(lightAnchor)
        
        // Add ambient light
        let ambientLight = DirectionalLight()
        ambientLight.light.intensity = 500
        ambientLight.light.color = .white
        lightAnchor.addChild(ambientLight)
    }
    
    private func createAnchorEntity(with entity: Entity) -> AnchorEntity {
        let anchor = AnchorEntity()
        anchor.addChild(entity)
        return anchor
    }
}
