//
//  FileSystemManager.swift
//  Menata
//
//  Created by Muhamad Azis on 24/06/25.
//

import Foundation
import os
import Folder

@MainActor
class FileSystemManager: ObservableObject {
    static let shared = FileSystemManager()
    private let logger = Logger(subsystem: "MenataApp", category: "FileSystemManager")
    
    // MARK: - Directory Paths
        private var documentsDirectory: URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
        
        private var roomsDirectory: URL {
            documentsDirectory.appendingPathComponent("Rooms/Models")
        }
        
        private var objectsDirectory: URL {
            documentsDirectory.appendingPathComponent("Objects/Models")
        }
        
        private init() {}

    
    // MARK: - Room Management
    func getRoomsFromFileSystem() -> [RoomCaptured] {
        scanForUSZDFiles(in: roomsDirectory, type: .room)
    }
    
    // MARK: - Object Management
    func getObjectsFromFileSystem() -> [ObjectCaptured] {
        scanForUSZDFiles(in: objectsDirectory, type: .object)
    }
    
    // MARK: - Generic USDZ Scanner
    private func scanForUSZDFiles<T>(in directory: URL, type: FileType) -> [T] {
        let fileManager = FileManager.default
        var results: [T] = []
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )
            
            let usdzFiles = contents.filter { $0.pathExtension.lowercased() == "usdz" }
            
            for file in usdzFiles {
                if let item = createCapturedItem(from: file, type: type) as? T {
                    results.append(item)
                }
            }
            
        } catch {
            logger.error("Failed to scan directory \(directory.path): \(error.localizedDescription)")
        }
        
        return results.sorted { (first, second) in
            let firstDate = getModificationDate(first)
            let secondDate = getModificationDate(second)
            return firstDate > secondDate // Newest first
        }
    }
    
    private func createCapturedItem(from url: URL, type: FileType) -> Any? {
        let fileName = url.deletingPathExtension().lastPathComponent
        let fileSize = getFileSize(for: url)
        let modificationDate = getFileModificationDate(url)
        
        switch type {
        case .room:
            return RoomCaptured(
                name: formatDisplayName(fileName),
                fileName: fileName,
                usdzFileName: fileName,
                captureDate: modificationDate,
                fileSize: fileSize,
                localURL: url
            )
        case .object:
            return ObjectCaptured(
                name: formatDisplayName(fileName),
                fileName: fileName,
                usdzFileName: fileName,
                captureDate: modificationDate,
                fileSize: fileSize,
                localURL: url
            )
        }
    }
    
    private func formatDisplayName(_ fileName: String) -> String {
        // Convert snake_case or camelCase to readable format
        return fileName
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
    
    private func getFileSize(for url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? NSNumber {
                let sizeInMB = Double(fileSize.intValue) / (1024 * 1024)
                if sizeInMB < 1.0 {
                    let sizeInKB = Double(fileSize.intValue) / 1024
                    return String(format: "%.0f KB", sizeInKB)
                } else {
                    return String(format: "%.1f MB", sizeInMB)
                }
            }
        } catch {
            logger.warning("Failed to get file size for \(url.path): \(error.localizedDescription)")
        }
        return "Unknown"
    }
    
    private func getFileModificationDate(_ url: URL) -> Date {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.modificationDate] as? Date ?? Date()
        } catch {
            logger.warning("Failed to get modification date for \(url.path): \(error.localizedDescription)")
            return Date()
        }
    }
    
    private func getModificationDate<T>(_ item: T) -> Date {
        if let room = item as? RoomCaptured {
            return room.captureDate
        } else if let object = item as? ObjectCaptured {
            return object.captureDate
        }
        return Date()
    }
    
    // MARK: - File Operations
    func deleteFile(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
        logger.log("Successfully deleted file at: \(url.path)")
    }
    
    enum FileType {
        case room, object
    }
}
