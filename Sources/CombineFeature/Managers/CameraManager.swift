//
//  CameraManager.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import Foundation
import RealityKit
import ARKit
import simd

class CameraManager {
    
    static func setupCamera(_ arView: ARView, coordinator: CanvasCoordinator) {
        let cameraEntity = PerspectiveCamera()
        let cameraAnchor = AnchorEntity()
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)
        
        // Store camera reference in coordinator
        coordinator.cameraEntity = cameraEntity
        coordinator.cameraAnchor = cameraAnchor
        
        // Set initial camera position
        coordinator.updateCameraPosition()
    }
    
    static func updateCameraPosition(coordinator: CanvasCoordinator) {
        guard let cameraEntity = coordinator.cameraEntity else { return }
        
        // Calculate new camera position based on spherical coordinates
        let x = coordinator.cameraDistance * cos(coordinator.cameraVerticalAngle) * cos(coordinator.cameraHorizontalAngle)
        let y = coordinator.cameraDistance * sin(coordinator.cameraVerticalAngle)
        let z = coordinator.cameraDistance * cos(coordinator.cameraVerticalAngle) * sin(coordinator.cameraHorizontalAngle)
        
        coordinator.cameraPosition = coordinator.canvasCenter + SIMD3<Float>(x, y, z)
        
        // Update camera transform
        cameraEntity.position = coordinator.cameraPosition
        cameraEntity.look(at: coordinator.canvasCenter, from: coordinator.cameraPosition, relativeTo: nil)
    }
    
    static func rotateCanvas(translation: CGPoint, coordinator: CanvasCoordinator) {
        let sensitivity: Float = 0.01
        
        // Horizontal movement = horizontal rotation
        if abs(translation.x) > abs(translation.y) {
            coordinator.cameraHorizontalAngle += Float(translation.x) * sensitivity
        } else {
            // Vertical movement = vertical rotation
            coordinator.cameraVerticalAngle -= Float(translation.y) * sensitivity
            coordinator.cameraVerticalAngle = max(-Float.pi/2 + 0.1, min(Float.pi/2 - 0.1, coordinator.cameraVerticalAngle))
        }
        
        updateCameraPosition(coordinator: coordinator)
    }
    
    static func panCanvas(translation: CGPoint, coordinator: CanvasCoordinator) {
        guard let cameraEntity = coordinator.cameraEntity else { return }
        
        let sensitivity: Float = 0.02
        
        // Get camera's right and forward vectors
        let cameraTransform = cameraEntity.transform
        let cameraRight = normalize(SIMD3<Float>(cameraTransform.matrix.columns.0.x, 0, cameraTransform.matrix.columns.0.z))
        let cameraForward = normalize(SIMD3<Float>(-cameraTransform.matrix.columns.2.x, 0, -cameraTransform.matrix.columns.2.z))
        
        // Convert screen translation to world movement
        let rightMovement = cameraRight * Float(-translation.x) * sensitivity
        let forwardMovement = cameraForward * Float(translation.y) * sensitivity
        
        coordinator.canvasCenter += rightMovement + forwardMovement
        
        updateCameraPosition(coordinator: coordinator)
    }
    
    static func zoomCanvas(scale: Float, coordinator: CanvasCoordinator) {
        coordinator.cameraDistance = max(2.0, min(50.0, coordinator.cameraDistance / scale))
        updateCameraPosition(coordinator: coordinator)
    }
}
