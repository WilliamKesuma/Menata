//
//  ObjecrCaptures.swift
//  Menata
//
//  Created by Muhamad Azis on 24/06/25.
//

import Foundation

struct ObjectCaptured: Identifiable, Hashable {
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
    
    // Initializer untuk file system
    init(name: String, fileName: String, usdzFileName: String, captureDate: Date, fileSize: String, localURL: URL?) {
        self.name = name
        self.fileName = fileName
        self.usdzFileName = usdzFileName
        self.captureDate = captureDate
        self.fileSize = fileSize
        self.localURL = localURL
    }
    
    // Initializer untuk bundle resources
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
extension ObjectCaptured {
    static var availableObjects: [ObjectCaptured] {
        var allObjects: [ObjectCaptured] = []
        
        let fileSystemObjects = FileSystemManager.shared.getObjectsFromFileSystem()
        allObjects.append(contentsOf: fileSystemObjects)
        
        let bundleObjects = getBundleObjects()
        
        let existingFileNames = Set(fileSystemObjects.map { $0.usdzFileName })
        let uniqueBundleObjects = bundleObjects.filter { !existingFileNames.contains($0.usdzFileName) }
        
        allObjects.append(contentsOf: uniqueBundleObjects)
        
        return allObjects.sorted { $0.captureDate > $1.captureDate }
    }
    
    private static func getBundleObjects() -> [ObjectCaptured] {
        let bundleFiles = [
            ("Kursi", "kursi_scan", "Kursi"),
            ("Vanesh", "vanesh_scan", "Vanesh"),
            ("Kursi Kotak", "kursi_kotak_scan", "KursiKotak"),
            ("Kursi Kotak 1", "kursi_kotak1_scan", "KursiKoTAK1")
        ]
        
        return bundleFiles.compactMap { (name, fileName, usdzName) in
            guard Bundle.main.url(forResource: usdzName, withExtension: "usdz") != nil else {
                return nil
            }
            
            return ObjectCaptured(
                name: name,
                fileName: fileName,
                usdzFileName: usdzName,
                captureDate: Date().addingTimeInterval(-Double.random(in: 43200...604800)), // Random date within last week
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
