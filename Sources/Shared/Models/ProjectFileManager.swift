//
//  ProjectFileManager.swift
//  Menata
//
//  Created by Muhamad Azis on 25/06/25.
//

import Foundation
import UIKit

@MainActor
class ProjectFileManager: ObservableObject {
    static let shared = ProjectFileManager()
    
    private let fileManager = FileManager.default
    private let projectsDirectoryName = "Projects"
    
    // MARK: - Directory URLs
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var projectsDirectory: URL {
        documentsDirectory.appendingPathComponent("Projects")
    }
    
    private init() {
        setupDirectories()
    }
    
    // MARK: - Directory Setup
    private func setupDirectories() {
        do {
            if !fileManager.fileExists(atPath: projectsDirectory.path) {
                try fileManager.createDirectory(at: projectsDirectory, withIntermediateDirectories: true)
                print("📁 Created Projects directory: \(projectsDirectory.path)")
            }
        } catch {
            print("❌ Failed to create directories: \(error)")
        }
    }
    
    // MARK: - Project File Operations
    func createProjectDirectory(for project: Project) throws -> String {
        let projectFolderName = sanitizeFileName(project.displayName + "_" + project.id.uuidString.prefix(8))
        let projectDir = projectsDirectory.appendingPathComponent(projectFolderName)
        
        try fileManager.createDirectory(at: projectDir, withIntermediateDirectories: true)
        
        let assetsDir = projectDir.appendingPathComponent("Assets")
        try fileManager.createDirectory(at: assetsDir, withIntermediateDirectories: true)
        
        print("📁 Created project directory: \(projectDir.path)")
        return projectDir.path
    }
    
    func saveProjectMetadata(_ project: Project) throws {
        guard let projectDir = project.projectDirectoryURL else {
            throw ProjectFileError.invalidProjectPath
        }
        
        let metadataURL = projectDir.appendingPathComponent("project.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(project)
        try data.write(to: metadataURL)
        
        print("💾 Saved project metadata: \(metadataURL.path)")
    }
    
    func loadProjectMetadata(from directoryPath: String) throws -> Project {
        let projectDir = URL(fileURLWithPath: directoryPath)
        let metadataURL = projectDir.appendingPathComponent("project.json")
        
        let data = try Data(contentsOf: metadataURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        var project = try decoder.decode(Project.self, from: data)
        project.projectFolderPath = directoryPath
        
        return project
    }
    
    func copyRoomFile(from sourceRoom: RoomCaptured, to project: Project) throws -> String {
        guard let projectDir = project.projectDirectoryURL,
              let assetsDir = project.assetsDirectoryURL else {
            throw ProjectFileError.invalidProjectPath
        }
        
        let originalFileName = "\(sourceRoom.usdzFileName).usdz"
        let destinationURL = assetsDir.appendingPathComponent(originalFileName)
        
        var sourceURL: URL
        if let localURL = sourceRoom.localURL {
            sourceURL = localURL
        } else {
            guard let bundleURL = Bundle.main.url(forResource: sourceRoom.usdzFileName, withExtension: "usdz") else {
                throw ProjectFileError.sourceFileNotFound
            }
            sourceURL = bundleURL
        }
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        
        print("📁 Copied room file: \(sourceURL.lastPathComponent) -> \(destinationURL.lastPathComponent)")
        print("   Source: \(sourceURL.path)")
        print("   Destination: \(destinationURL.path)")
        
        return originalFileName
    }
    
    func saveThumbnail(_ image: UIImage, for project: Project) throws {
        guard let projectDir = project.projectDirectoryURL else {
            throw ProjectFileError.invalidProjectPath
        }
        
        let thumbnailURL = projectDir.appendingPathComponent("thumbnail.png")
        
        guard let data = image.pngData() else {
            throw ProjectFileError.thumbnailGenerationFailed
        }
        
        try data.write(to: thumbnailURL)
        print("🖼️ Saved thumbnail: \(thumbnailURL.path)")
    }
    
    func loadThumbnail(for project: Project) -> UIImage? {
        guard let thumbnailURL = project.projectThumbnailURL,
              fileManager.fileExists(atPath: thumbnailURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: thumbnailURL.path)
    }
    
    func deleteProject(_ project: Project) throws {
        guard let projectDir = project.projectDirectoryURL,
              fileManager.fileExists(atPath: projectDir.path) else {
            return
        }
        
        try fileManager.removeItem(at: projectDir)
        print("🗑️ Deleted project directory: \(projectDir.path)")
    }
    
    // MARK: - Load All Projects
    func loadAllProjects() throws -> [Project] {
        var projects: [Project] = []
        
        guard fileManager.fileExists(atPath: projectsDirectory.path) else {
            return projects
        }
        
        let projectDirectories = try fileManager.contentsOfDirectory(at: projectsDirectory, includingPropertiesForKeys: nil)
        
        for directory in projectDirectories {
            do {
                let project = try loadProjectMetadata(from: directory.path)
                projects.append(project)
            } catch {
                print("⚠️ Failed to load project from \(directory.path): \(error)")
                // Continue loading other projects
            }
        }
        
        projects.sort { $0.createdDate > $1.createdDate }
        
        print("📁 Loaded \(projects.count) projects from file system")
        return projects
    }
    
    // MARK: - Utility Functions
    private func sanitizeFileName(_ fileName: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return fileName.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
    
    func getProjectsDirectorySize() -> String {
        guard let enumerator = fileManager.enumerator(at: projectsDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 B"
        }
        
        var totalSize: Int64 = 0
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                totalSize += Int64(resourceValues.fileSize ?? 0)
            } catch {
                continue
            }
        }
        
        return ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    func getProjectFileCount(for project: Project) -> Int {
        guard let projectDir = project.projectDirectoryURL,
              let enumerator = fileManager.enumerator(at: projectDir, includingPropertiesForKeys: nil) else {
            return 0
        }
        
        return enumerator.allObjects.count
    }
}

enum ProjectFileError: LocalizedError {
    case invalidProjectPath
    case sourceFileNotFound
    case thumbnailGenerationFailed
    case projectDirectoryNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidProjectPath:
            return "Invalid project path"
        case .sourceFileNotFound:
            return "Source file not found"
        case .thumbnailGenerationFailed:
            return "Failed to generate thumbnail"
        case .projectDirectoryNotFound:
            return "Project directory not found"
        }
    }
}
