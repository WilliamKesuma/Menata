////
////  RoomAnchorManager.swift
////  Menata
////
////  Created by Muhamad Azis on 25/06/25.
////
//
//import Foundation
//import RealityKit
//import ARKit
//
//class RoomAnchorManager {
//    
//    @MainActor static func setupRoomAnchor(project: Project, arView: ARView, coordinator: CanvasCoordinator) {
//        guard let selectedRoom = project.selectedRoom else {
//            print("🏠 No room selected for project")
//            return
//        }
//        
//        // Load room USDZ file
//        loadRoomAsset(for: project, selectedRoom: selectedRoom, arView: arView, coordinator: coordinator)
//    }
//    
//    @MainActor private static func loadRoomAsset(for project: Project, selectedRoom: RoomCaptured, arView: ARView, coordinator: CanvasCoordinator) {
//        
//        // Priority 1: Try to load from project assets first
//        if let roomEntity = loadFromProjectAssets(project: project) {
//            addRoomAnchor(entity: roomEntity, name: selectedRoom.name, arView: arView, coordinator: coordinator)
//            return
//        }
//        
//        // Priority 2: Try to load from selectedRoom.localURL (captured rooms)
//        if let localURL = selectedRoom.localURL {
//            loadFromURL(url: localURL, name: selectedRoom.name, arView: arView, coordinator: coordinator)
//            return
//        }
//        
//        // Priority 3: Try to load from bundle (sample rooms)
//        if let bundleURL = Bundle.main.url(forResource: selectedRoom.usdzFileName, withExtension: "usdz") {
//            loadFromURL(url: bundleURL, name: selectedRoom.name, arView: arView, coordinator: coordinator)
//            return
//        }
//        
//        // Fallback: Create placeholder room
//        createPlaceholderRoom(name: selectedRoom.name, arView: arView, coordinator: coordinator)
//    }
//    
//    @MainActor private static func loadFromProjectAssets(project: Project) -> ModelEntity? {
//        guard let assetsDir = project.assetsDirectoryURL else { return nil }
//        
//        do {
//            let files = try FileManager.default.contentsOfDirectory(atPath: assetsDir.path)
//            let usdzFiles = files.filter { $0.hasSuffix(".usdz") }
//            
//            if let firstUSDZ = usdzFiles.first {
//                let assetURL = assetsDir.appendingPathComponent(firstUSDZ)
//                print("🏠 Loading room from project assets: \(assetURL.path)")
//                return try ModelEntity.load(contentsOf: assetURL) as! ModelEntity
//            }
//        } catch {
//            print("❌ Error loading from project assets: \(error)")
//        }
//        
//        return nil
//    }
//    
//    private static func loadFromURL(url: URL, name: String, arView: ARView, coordinator: CanvasCoordinator) {
//        print("🏠 Loading room from URL: \(url.path)")
//        
//        Task {
//            do {
//                let roomEntity = try await ModelEntity.load(contentsOf: url)
//                await MainActor.run {
//                    addRoomAnchor(entity: roomEntity as! ModelEntity, name: name, arView: arView, coordinator: coordinator)
//                }
//            } catch {
//                print("❌ Error loading room from URL \(url.path): \(error)")
//                await MainActor.run {
//                    createPlaceholderRoom(name: "\(name) (Load Failed)", arView: arView, coordinator: coordinator)
//                }
//            }
//        }
//    }
//    
//    @MainActor private static func addRoomAnchor(entity: ModelEntity, name: String, arView: ARView, coordinator: CanvasCoordinator) {
//        // Set room properties
//        entity.name = "RoomAnchor_\(name)"
//        
//        // Position room at origin (center of canvas)
//        entity.position = SIMD3<Float>(0, 0, 0)
//        
//        // Scale room appropriately (adjust as needed)
//        entity.scale = SIMD3<Float>(1.0, 1.0, 1.0)
//        
//        // Make room unselectable by adding specific material
//        applyRoomStyling(to: entity)
//        
//        // Create room anchor that's attached to the scene
//        let roomAnchor = AnchorEntity()
//        roomAnchor.addChild(entity)
//        roomAnchor.name = "RoomAnchor"
//        
//        arView.scene.addAnchor(roomAnchor)
//        
//        // Store reference in coordinator
//        coordinator.roomAnchor = roomAnchor
//        coordinator.roomEntity = entity
//        
//        print("🏠 Room anchor added successfully: \(name)")
//    }
//    
//    @MainActor private static func createPlaceholderRoom(name: String, arView: ARView, coordinator: CanvasCoordinator) {
//        print("🏠 Creating placeholder room: \(name)")
//        
//        // Create a simple box as placeholder
//        let mesh = MeshResource.generateBox(size: [4, 0.1, 4])
//        let material = SimpleMaterial(color: .lightGray, isMetallic: false)
//        
//        let roomEntity = ModelEntity(mesh: mesh, materials: [material])
//        roomEntity.name = "RoomAnchor_\(name)_Placeholder"
//        
//        // Add some visual indication it's a placeholder
//        let borderMesh = MeshResource.generateBox(size: [4.1, 0.15, 4.1])
//        let borderMaterial = SimpleMaterial(color: .gray, isMetallic: false)
//        let borderEntity = ModelEntity(mesh: borderMesh, materials: [borderMaterial])
//        borderEntity.position.y = -0.025
//        roomEntity.addChild(borderEntity)
//        
//        // Add text indicator
//        addPlaceholderText(to: roomEntity, text: "ROOM: \(name)")
//        
//        addRoomAnchor(entity: roomEntity, name: "\(name) (Placeholder)", arView: arView, coordinator: coordinator)
//    }
//    
//    private static func addPlaceholderText(to entity: ModelEntity, text: String) {
//        // Create text mesh (simplified version - you might want to use more sophisticated text rendering)
//        let textMesh = MeshResource.generateBox(size: [0.1, 0.1, 0.1])
//        let textMaterial = SimpleMaterial(color: .black, isMetallic: false)
//        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
//        textEntity.position = SIMD3<Float>(0, 0.2, 0)
//        textEntity.name = "PlaceholderText"
//        
//        entity.addChild(textEntity)
//    }
//    
//    private static func applyRoomStyling(to entity: ModelEntity) {
//        // Apply semi-transparent material to make room visible but distinct
//        applyMaterialRecursively(to: entity)
//        
//        // Add wireframe outline for better visibility
//        addWireframeOutline(to: entity)
//    }
//    
//    private static func applyMaterialRecursively(to entity: Entity) {
//        if let modelEntity = entity as? ModelEntity, modelEntity.model != nil {
//            // Create semi-transparent material
//            var material = SimpleMaterial()
//            material.color = .init(tint: .white.withAlphaComponent(0.7))
//            material.metallic = 0.1
//            material.roughness = 0.8
//            
//            modelEntity.model?.materials = [material]
//        }
//        
//        // Apply to children recursively
//        for child in entity.children {
//            applyMaterialRecursively(to: child)
//        }
//    }
//    
//    private static func addWireframeOutline(to entity: ModelEntity) {
//        // Get entity bounds
//        let bounds = entity.model?.mesh.bounds ?? BoundingBox(
//            min: SIMD3<Float>(-2, -0.1, -2),
//            max: SIMD3<Float>(2, 0.1, 2)
//        )
//        let size = bounds.max - bounds.min
//        
//        // Ensure minimum size for wireframe
//        let wireframeSize = SIMD3<Float>(
//            max(size.x, 0.5),
//            max(size.y, 0.1),
//            max(size.z, 0.5)
//        ) * 1.01 // Slightly larger
//        
//        // Create wireframe box
//        let wireframeMesh = MeshResource.generateBox(size: wireframeSize)
//        var wireframeMaterial = UnlitMaterial()
//        wireframeMaterial.color = .init(tint: .blue.withAlphaComponent(0.5))
//        
//        let wireframeEntity = ModelEntity(mesh: wireframeMesh, materials: [wireframeMaterial])
//        wireframeEntity.name = "RoomWireframe"
//        
//        // Position wireframe at entity center
//        let center = (bounds.min + bounds.max) / 2
//        wireframeEntity.position = center
//        
//        entity.addChild(wireframeEntity)
//    }
//    
//    // Function to update room rotation based on canvas rotation
//    static func updateRoomRotation(coordinator: CanvasCoordinator) {
//        guard let roomAnchor = coordinator.roomAnchor else { return }
//        
//        // Room should not rotate independently - it stays fixed to the world
//        // This ensures the room appears to rotate with the canvas view
//        // The room stays at world origin (0,0,0) and doesn't move
//        
//        // If you want the room to appear stationary relative to the camera:
//        // roomAnchor.orientation = simd_quatf(angle: -coordinator.cameraHorizontalAngle, axis: [0, 1, 0])
//    }
//}
