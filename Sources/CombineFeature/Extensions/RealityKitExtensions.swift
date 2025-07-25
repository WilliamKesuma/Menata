//
//  RealityKitExtensions.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import RealityKit
import UIKit
import ARKit

// MARK: - Coordinator for Gesture Handling
class CanvasCoordinator: NSObject {
    var parent: RealityKitCanvasView
    var arView: ARView?
    var selectedEntity: ModelEntity?
    var selectionIndicator: Entity?
    var cameraEntity: PerspectiveCamera?
    var cameraAnchor: AnchorEntity?
    var gridAnchor: AnchorEntity?
    var allObjects: [Entity] = []
    
    // Camera control properties
    var cameraDistance: Float = 8.66
    var cameraVerticalAngle: Float = 0.615
    var cameraHorizontalAngle: Float = 0.785
    var canvasCenter = SIMD3<Float>(0, 0, 0)
    var cameraPosition = SIMD3<Float>(5, 5, 5)
    
    init(_ parent: RealityKitCanvasView) {
        self.parent = parent
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let location = gesture.location(in: arView)
        
        // Remove previous selection
        SelectionManager.removeSelectionIndicator(coordinator: self)
        selectedEntity = nil
        
        print("Tap detected at: \(location)")
        
        // Check if tapping on an object
        if let entity = arView.entity(at: location) as? ModelEntity {
            print("Entity found: \(entity.name)")
            
            // Check if it's a valid selectable entity
            if entity.name != "GridFloor" &&
               entity.name != "SelectionIndicator" &&
               !entity.name.contains("WireBorder") &&
               !entity.name.contains("WireFrame") {
                selectedEntity = entity
                SelectionManager.showSelectionIndicator(for: entity, coordinator: self)
                print("Selected entity: \(entity.name)")
            }
        } else {
            print("No entity found at tap location")
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let arView = arView else { return }
        
        let translation = gesture.translation(in: arView)
        let numberOfTouches = gesture.numberOfTouches
        
        switch gesture.state {
        case .began:
            print("Pan began - touches: \(numberOfTouches), selected: \(selectedEntity?.name ?? "none")")
            
        case .changed:
            if let entity = selectedEntity, numberOfTouches == 1 {
                // Move selected object dengan 1 jari
                print("Moving selected object: \(entity.name)")
                moveSelectedObjectWithYAxis(translation: translation, in: arView)
            } else {
                if numberOfTouches == 1 {
                    // Rotate canvas with one finger
                    print("Rotating canvas with 1 finger")
                    CameraManager.rotateCanvas(translation: translation, coordinator: self)
                } else if numberOfTouches == 2 {
                    // Pan canvas with two fingers
                    print("Panning canvas with 2 fingers")
                    CameraManager.panCanvas(translation: translation, coordinator: self)
                }
            }
            gesture.setTranslation(.zero, in: arView)
            
        case .ended:
            if let entity = selectedEntity {
                SelectionManager.snapToGrid(entity: entity, coordinator: self)
            }
            
        default:
            break
        }
        
        // Update grid position for infinite effect
        GridManager.updateGridPosition(coordinator: self)
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let scale = Float(gesture.scale)
        
        if let entity = selectedEntity {
            // Scale selected object
            print("Scaling selected object: \(entity.name)")
            entity.scale = entity.scale * scale
            SelectionManager.updateSelectionIndicatorPosition(coordinator: self)
        } else {
            // Zoom canvas
            print("Zooming canvas")
            CameraManager.zoomCanvas(scale: scale, coordinator: self)
        }
        
        gesture.scale = 1.0
    }
    
    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        if let entity = selectedEntity {
            print("Rotating selected object: \(entity.name)")
            let rotation = Float(gesture.rotation)
            entity.orientation = simd_quatf(angle: rotation, axis: [0, 1, 0]) * entity.orientation
            gesture.rotation = 0
        }
    }
    
    func updateCameraPosition() {
        CameraManager.updateCameraPosition(coordinator: self)
    }
    
    private func moveSelectedObjectWithYAxis(translation: CGPoint, in arView: ARView) {
        guard let entity = selectedEntity,
              let cameraEntity = cameraEntity else { return }
        
        let sensitivity: Float = 0.01
        
        // Get camera's right and up vectors
        let cameraTransform = cameraEntity.transform
        let cameraRight = normalize(SIMD3<Float>(cameraTransform.matrix.columns.0.x, 0, cameraTransform.matrix.columns.0.z))
        let cameraUp = SIMD3<Float>(0, 1, 0)
        
        // Horizontal movement (X and Z)
        let rightMovement = cameraRight * Float(translation.x) * sensitivity
        
        // Vertical movement (Y) - negative because screen Y is inverted
        let upMovement = cameraUp * Float(-translation.y) * sensitivity
        
        entity.position += rightMovement + upMovement
        
        // Update selection indicator position
        SelectionManager.updateSelectionIndicatorPosition(coordinator: self)
    }
}
