//
//  Project.swift
//  Menata
//
//  Created by Muhamad Azis on 17/06/25.
//

import Foundation

@MainActor
struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var selectedRoomId: String?
    let createdDate: Date
    var lastModified: Date
    var thumbnailData: Data?
    var projectFolderPath: String?
    
    var selectedRoom: RoomCaptured? {
        get {
            guard let roomId = selectedRoomId else { return nil }
            return RoomCaptured.availableRooms.first { $0.id.uuidString == roomId }
        }
        set {
            selectedRoomId = newValue?.id.uuidString
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case selectedRoomId
        case createdDate
        case lastModified
        case thumbnailData
        case projectFolderPath
    }
    
    init(id: UUID = UUID(), name: String, selectedRoomId: String? = nil, selectedRoom: RoomCaptured? = nil) {
        self.id = id
        self.name = name
        self.selectedRoomId = selectedRoomId
        self.createdDate = Date()
        self.lastModified = Date()
        self.projectFolderPath = nil
        
        if let room = selectedRoom {
            self.selectedRoomId = room.id.uuidString
        }
    }
    
    var displayName: String {
        return name.isEmpty ? "Untitled Project" : name
    }
    
    var hasRoom: Bool {
        return selectedRoomId != nil && selectedRoom != nil
    }
    
    var roomSource: String? {
        guard let room = selectedRoom else { return nil }
        return room.localURL != nil ? "Captured" : "Sample"
    }
    
    // MARK: - File Manager Properties
    var projectDirectoryURL: URL? {
        guard let folderPath = projectFolderPath else { return nil }
        return URL(fileURLWithPath: folderPath)
    }
    
    var projectMetadataURL: URL? {
        return projectDirectoryURL?.appendingPathComponent("project.json")
    }
    
    var projectThumbnailURL: URL? {
        return projectDirectoryURL?.appendingPathComponent("thumbnail.png")
    }
    
    var assetsDirectoryURL: URL? {
        return projectDirectoryURL?.appendingPathComponent("Assets")
    }
    
    var roomUsdzURL: URL? {
        return assetsDirectoryURL?.appendingPathComponent("room.usdz")
    }
    
    var objectUsdzURL: URL? {
        return assetsDirectoryURL?.appendingPathComponent("object.usdz")
    }
}

// MARK: - Sample Data
extension Project {
    static let sampleProjects: [Project] = []
}
