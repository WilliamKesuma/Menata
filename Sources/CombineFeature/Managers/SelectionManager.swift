//
//  SelectionManager.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import Foundation
import RealityKit
import UIKit
import simd

class SelectionManager {
    
    static func showSelectionIndicator(for entity: ModelEntity, coordinator: CanvasCoordinator) {
        removeSelectionIndicator(coordinator: coordinator)
        
        // Calculate accurate bounding box with padding
        let bounds = calculateEntityBounds(entity)
        let padding: Float = 0.1 // Add padding around the object
        let size = SIMD3<Float>(
            bounds.max.x - bounds.min.x + padding,
            bounds.max.y - bounds.min.y + padding,
            bounds.max.z - bounds.min.z + padding
        )
        
        // Calculate center offset if the object is not centered
        let center = SIMD3<Float>(
            (bounds.max.x + bounds.min.x) / 2,
            (bounds.max.y + bounds.min.y) / 2,
            (bounds.max.z + bounds.min.z) / 2
        )
        
        print("Creating wireframe - size: \(size), center: \(center)")
        
        // Create wireframe bounding box
        coordinator.selectionIndicator = createWireBoundingBox(size: size, centerOffset: center)
        coordinator.selectionIndicator?.name = "SelectionIndicator"
        
        updateSelectionIndicatorPosition(coordinator: coordinator)
        
        if let anchor = entity.anchor {
            anchor.addChild(coordinator.selectionIndicator!)
            print("Added wireframe to anchor")
        } else {
            print("No anchor found for entity")
        }
    }
    
    static func updateSelectionIndicatorPosition(coordinator: CanvasCoordinator) {
        guard let entity = coordinator.selectedEntity else { return }
        coordinator.selectionIndicator?.position = entity.position
        coordinator.selectionIndicator?.orientation = entity.orientation
        // Don't scale the wireframe with the object to maintain consistent line thickness
        // coordinator.selectionIndicator?.scale = entity.scale
    }
    
    static func removeSelectionIndicator(coordinator: CanvasCoordinator) {
        coordinator.selectionIndicator?.removeFromParent()
        coordinator.selectionIndicator = nil
    }
    
    private static func calculateEntityBounds(_ entity: ModelEntity) -> BoundingBox {
        // Try to get accurate bounds from the entity
        if let model = entity.model {
            let meshBounds = model.mesh.bounds
            
            // Transform bounds by entity's scale
            let scaledMin = meshBounds.min * entity.scale
            let scaledMax = meshBounds.max * entity.scale
            
            // Calculate bounds for all child entities too
            var totalMin = scaledMin
            var totalMax = scaledMax
            
            for child in entity.children {
                if let childModel = child as? ModelEntity, let childModelComponent = childModel.model {
                    let childBounds = childModelComponent.mesh.bounds
                    let childPos = child.position
                    let childScale = child.scale
                    
                    let childMin = (childBounds.min * childScale) + childPos
                    let childMax = (childBounds.max * childScale) + childPos
                    
                    totalMin = SIMD3<Float>(
                        min(totalMin.x, childMin.x),
                        min(totalMin.y, childMin.y),
                        min(totalMin.z, childMin.z)
                    )
                    totalMax = SIMD3<Float>(
                        max(totalMax.x, childMax.x),
                        max(totalMax.y, childMax.y),
                        max(totalMax.z, childMax.z)
                    )
                }
            }
            
            return BoundingBox(min: totalMin, max: totalMax)
        } else {
            // Fallback for entities without model component
            return BoundingBox(
                min: SIMD3<Float>(-0.5, -0.5, -0.5),
                max: SIMD3<Float>(0.5, 0.5, 0.5)
            )
        }
    }
    
    private static func createWireBoundingBox(size: SIMD3<Float>, centerOffset: SIMD3<Float> = SIMD3<Float>(0, 0, 0)) -> Entity {
        let wireframe = Entity()
        wireframe.position = centerOffset // Apply center offset if object is not centered
        
        let lineWidth: Float = 0.03  // Slightly thicker lines
        let lineColor = UIColor.systemYellow
        let lineMaterial = SimpleMaterial(color: lineColor, isMetallic: false)
        
        // Ensure minimum size for visibility
        let finalSize = SIMD3<Float>(
            max(size.x, 0.1),
            max(size.y, 0.1),
            max(size.z, 0.1)
        )
        
        // Create 12 edges of a bounding box
        let edges: [(SIMD3<Float>, SIMD3<Float>)] = [
            // Bottom face (Y = -finalSize.y/2)
            (SIMD3<Float>(-finalSize.x/2, -finalSize.y/2, -finalSize.z/2), SIMD3<Float>(finalSize.x/2, -finalSize.y/2, -finalSize.z/2)),
            (SIMD3<Float>(finalSize.x/2, -finalSize.y/2, -finalSize.z/2), SIMD3<Float>(finalSize.x/2, -finalSize.y/2, finalSize.z/2)),
            (SIMD3<Float>(finalSize.x/2, -finalSize.y/2, finalSize.z/2), SIMD3<Float>(-finalSize.x/2, -finalSize.y/2, finalSize.z/2)),
            (SIMD3<Float>(-finalSize.x/2, -finalSize.y/2, finalSize.z/2), SIMD3<Float>(-finalSize.x/2, -finalSize.y/2, -finalSize.z/2)),
            
            // Top face (Y = finalSize.y/2)
            (SIMD3<Float>(-finalSize.x/2, finalSize.y/2, -finalSize.z/2), SIMD3<Float>(finalSize.x/2, finalSize.y/2, -finalSize.z/2)),
            (SIMD3<Float>(finalSize.x/2, finalSize.y/2, -finalSize.z/2), SIMD3<Float>(finalSize.x/2, finalSize.y/2, finalSize.z/2)),
            (SIMD3<Float>(finalSize.x/2, finalSize.y/2, finalSize.z/2), SIMD3<Float>(-finalSize.x/2, finalSize.y/2, finalSize.z/2)),
            (SIMD3<Float>(-finalSize.x/2, finalSize.y/2, finalSize.z/2), SIMD3<Float>(-finalSize.x/2, finalSize.y/2, -finalSize.z/2)),
            
            // Vertical edges
            (SIMD3<Float>(-finalSize.x/2, -finalSize.y/2, -finalSize.z/2), SIMD3<Float>(-finalSize.x/2, finalSize.y/2, -finalSize.z/2)),
            (SIMD3<Float>(finalSize.x/2, -finalSize.y/2, -finalSize.z/2), SIMD3<Float>(finalSize.x/2, finalSize.y/2, -finalSize.z/2)),
            (SIMD3<Float>(finalSize.x/2, -finalSize.y/2, finalSize.z/2), SIMD3<Float>(finalSize.x/2, finalSize.y/2, finalSize.z/2)),
            (SIMD3<Float>(-finalSize.x/2, -finalSize.y/2, finalSize.z/2), SIMD3<Float>(-finalSize.x/2, finalSize.y/2, finalSize.z/2))
        ]
        
        for (i, edge) in edges.enumerated() {
            let start = edge.0
            let end = edge.1
            let center = (start + end) / 2
            let length = simd_length(end - start)
            
            // Skip zero-length edges
            guard length > 0.001 else {
                print("Skipping zero-length edge \(i)")
                continue
            }
            
            // Create line segment using cylinder for better orientation
            let lineMesh = MeshResource.generateCylinder(height: length, radius: lineWidth/2)
            let lineEntity = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            lineEntity.name = "WireFrame\(i)"
            
            lineEntity.position = center
            
            // Orient the line properly using LookAt
            let direction = normalize(end - start)
            let defaultDirection = SIMD3<Float>(0, 1, 0) // Cylinder's default direction is Y-up
            
            // Calculate rotation to align cylinder with edge direction
            if simd_length(cross(defaultDirection, direction)) > 0.001 {
                let rotationAxis = normalize(cross(defaultDirection, direction))
                let rotationAngle = acos(max(-1, min(1, dot(defaultDirection, direction))))
                lineEntity.orientation = simd_quatf(angle: rotationAngle, axis: rotationAxis)
            } else if dot(defaultDirection, direction) < 0 {
                // Handle 180-degree rotation
                lineEntity.orientation = simd_quatf(angle: Float.pi, axis: SIMD3<Float>(1, 0, 0))
            }
            
            wireframe.addChild(lineEntity)
        }
        
        print("Created wireframe with \(wireframe.children.count) edges")
        return wireframe
    }
    
    static func snapToGrid(entity: ModelEntity, coordinator: CanvasCoordinator) {
        let gridSize: Float = 0.5
        let snappedX = round(entity.position.x / gridSize) * gridSize
        let snappedZ = round(entity.position.z / gridSize) * gridSize
        
        entity.position = SIMD3<Float>(snappedX, entity.position.y, snappedZ)
        updateSelectionIndicatorPosition(coordinator: coordinator)
    }
}
