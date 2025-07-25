//
//  ObjectFactory.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import Foundation
import RealityKit
import simd

class ObjectFactory {
    
    static func createProceduralModel(named name: String) -> ModelEntity {
        switch name {
        case "OCKursi":
            return createChairModel()
        case "OCKursiKotak":
            return createTableModel()
        case "OCVanesh":
            return createBoxModel()
        default:
            return createBoxModel()
        }
    }
    
    private static func createChairModel() -> ModelEntity {
        let mesh = MeshResource.generateBox(width: 0.5, height: 0.8, depth: 0.5)
        let material = SimpleMaterial(color: .brown, roughness: 0.3, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
    
    private static func createTableModel() -> ModelEntity {
        let mesh = MeshResource.generateBox(width: 1.2, height: 0.1, depth: 0.8)
        let material = SimpleMaterial(color: .systemBrown, roughness: 0.2, isMetallic: false)
        let table = ModelEntity(mesh: mesh, materials: [material])
        
        // Add legs
        let legMesh = MeshResource.generateBox(width: 0.05, height: 0.7, depth: 0.05)
        let legMaterial = SimpleMaterial(color: .darkGray, roughness: 0.4, isMetallic: false)
        
        let positions = [
            SIMD3<Float>(0.55, -0.4, 0.35),
            SIMD3<Float>(-0.55, -0.4, 0.35),
            SIMD3<Float>(0.55, -0.4, -0.35),
            SIMD3<Float>(-0.55, -0.4, -0.35)
        ]
        
        for position in positions {
            let leg = ModelEntity(mesh: legMesh, materials: [legMaterial])
            leg.position = position
            table.addChild(leg)
        }
        
        return table
    }
    
    private static func createBoxModel() -> ModelEntity {
        let mesh = MeshResource.generateBox(width: 0.3, height: 0.3, depth: 0.3)
        let material = SimpleMaterial(color: .blue, roughness: 0.1, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}
