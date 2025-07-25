//
//  RoomCaptured.swift
//  Menata
//
//  Created by Muhamad Azis on 24/06/25.
//

import Foundation

struct RoomCaptured: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let fileName: String
    let usdzFileName: String
    let captureDate: Date
    let fileSize: String
    let localURL: URL?
    
    var usdzURL: URL? {
        // Prioritaskan local file jika ada
        if let localURL = localURL, FileManager.default.fileExists(atPath: localURL.path) {
            return localURL
        }
        // Fallback ke bundle resource
        return Bundle.main.url(forResource: usdzFileName, withExtension: "usdz")
    }
    
    var isAvailable: Bool {
        return usdzURL != nil
    }
    
    init(name: String, fileName: String, usdzFileName: String, captureDate: Date, fileSize: String, localURL: URL?) {
        self.name = name
        self.fileName = fileName
        self.usdzFileName = usdzFileName
        self.captureDate = captureDate
        self.fileSize = fileSize
        self.localURL = localURL
    }
    
    init(name: String, fileName: String, usdzFileName: String, captureDate: Date, fileSize: String) {
        self.name = name
        self.fileName = fileName
        self.usdzFileName = usdzFileName
        self.captureDate = captureDate
        self.fileSize = fileSize
        self.localURL = nil
    }
}

@MainActor
extension RoomCaptured {
    static var availableRooms: [RoomCaptured] {
        var allRooms: [RoomCaptured] = []
        
        let fileSystemRooms = FileSystemManager.shared.getRoomsFromFileSystem()
        allRooms.append(contentsOf: fileSystemRooms)
        
        let bundleRooms = getBundleRooms()
        
        let existingFileNames = Set(fileSystemRooms.map { $0.usdzFileName })
        let uniqueBundleRooms = bundleRooms.filter { !existingFileNames.contains($0.usdzFileName) }
        
        allRooms.append(contentsOf: uniqueBundleRooms)
        
        return allRooms.sorted { $0.captureDate > $1.captureDate }
    }
    
    private static func getBundleRooms() -> [RoomCaptured] {
        let bundleFiles = [
            ("Room 1", "room1_scan", "Room1"),
            ("Room 2", "room2_scan", "Room2")
        ]
        
        return bundleFiles.compactMap { (name, fileName, usdzName) in
            guard Bundle.main.url(forResource: usdzName, withExtension: "usdz") != nil else {
                return nil
            }
            
            return RoomCaptured(
                name: name,
                fileName: fileName,
                usdzFileName: usdzName,
                captureDate: Date().addingTimeInterval(-Double.random(in: 86400...604800)), 
                fileSize: getBundleFileSize(fileName: usdzName)
            )
        }
    }
    
    private static func getBundleFileSize(fileName: String) -> String {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "usdz"),
              let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let fileSize = attributes[.size] as? NSNumber else {
            return "Unknown"
        }
        
        let sizeInMB = Double(fileSize.intValue) / (1024 * 1024)
        if sizeInMB < 1.0 {
            let sizeInKB = Double(fileSize.intValue) / 1024
            return String(format: "%.0f KB", sizeInKB)
        } else {
            return String(format: "%.1f MB", sizeInMB)
        }
    }
}
