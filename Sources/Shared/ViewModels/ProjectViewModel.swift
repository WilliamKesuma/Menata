//
//  ProjectViewModel.swift
//  Menata
//
//  Created by Muhamad Azis on 17/06/25.
//

import Foundation
import SwiftUI

@MainActor
class ProjectViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var showingCreateProject = false
    @Published var selectedProject: Project?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let projectFileManager = ProjectFileManager.shared
    
    // Computed properties untuk akses data terbaru
    var availableRooms: [RoomCaptured] {
        RoomCaptured.availableRooms.filter { $0.isAvailable }
    }
    
    var availableObjects: [ObjectCaptured] {
        ObjectCaptured.availableObjects.filter { $0.isAvailable }
    }
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                self.projects = try self.projectFileManager.loadAllProjects()
                self.validateProjectRooms()
                print("📁 Loaded \(self.projects.count) projects from file system")
            } catch {
                print("❌ Failed to load projects: \(error)")
                self.errorMessage = "Failed to load projects: \(error.localizedDescription)"
                self.projects = []
            }
            
            self.isLoading = false
        }
    }
    
    private func validateProjectRooms() {
        var hasChanges = false
        
        for (index, project) in projects.enumerated() {
            if let roomId = project.selectedRoomId {
                let roomExists = availableRooms.contains { $0.id.uuidString == roomId }
                if !roomExists {
                    print("⚠️ Room for project '\(project.displayName)' no longer exists")
                    projects[index].selectedRoomId = nil
                    hasChanges = true
                }
            }
        }
        
        if hasChanges {
            // Update projects that need room validation
            for project in projects {
                do {
                    try projectFileManager.saveProjectMetadata(project)
                } catch {
                    print("❌ Failed to update project metadata: \(error)")
                }
            }
        }
    }
    
    func createProject(name: String, selectedRoom: RoomCaptured?) {
        isLoading = true
        errorMessage = nil
        
        let projectName = name.isEmpty ? generateDefaultName() : name
        
        var newProject = Project(
            name: projectName,
            selectedRoomId: selectedRoom?.id.uuidString,
            selectedRoom: selectedRoom
        )
        
        do {
            // Create project directory structure
            let projectPath = try projectFileManager.createProjectDirectory(for: newProject)
            newProject.projectFolderPath = projectPath
            
            // Copy room file if selected
            if let room = selectedRoom {
                try projectFileManager.copyRoomFile(from: room, to: newProject)
            }
            
            // Save project metadata
            try projectFileManager.saveProjectMetadata(newProject)
            
            // Generate and save thumbnail (placeholder for now)
            if let placeholderImage = generatePlaceholderThumbnail(for: newProject) {
                try projectFileManager.saveThumbnail(placeholderImage, for: newProject)
            }
            
            // Add to projects array
            projects.insert(newProject, at: 0) // Add to beginning for newest first
            
            print("✅ Successfully created project: \(projectName)")
            print("   - Project folder: \(projectPath)")
            print("   - Room: \(selectedRoom?.name ?? "None")")
            
        } catch {
            print("❌ Failed to create project: \(error)")
            errorMessage = "Failed to create project: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteProject(_ project: Project) {
        do {
            // Delete from file system
            try projectFileManager.deleteProject(project)
            
            // Remove from array
            projects.removeAll { $0.id == project.id }
            
            // Clear selection if needed
            if selectedProject?.id == project.id {
                selectedProject = nil
            }
            
            print("🗑️ Successfully deleted project: '\(project.displayName)'")
            
        } catch {
            print("❌ Failed to delete project: \(error)")
            errorMessage = "Failed to delete project: \(error.localizedDescription)"
        }
    }
    
    func updateProject(_ project: Project) {
        do {
            // Update last modified date
            var updatedProject = project
            updatedProject.lastModified = Date()
            
            // Save metadata to file system
            try projectFileManager.saveProjectMetadata(updatedProject)
            
            // Update in array
            if let index = projects.firstIndex(where: { $0.id == project.id }) {
                projects[index] = updatedProject
            }
            
            print("✏️ Successfully updated project: \(project.displayName)")
            
        } catch {
            print("❌ Failed to update project: \(error)")
            errorMessage = "Failed to update project: \(error.localizedDescription)"
        }
    }
    
    func updateProjectRoom(_ project: Project, newRoom: RoomCaptured?) {
        do {
            var updatedProject = project
            updatedProject.selectedRoom = newRoom
            updatedProject.lastModified = Date()
            
            // Copy new room file if provided
            if let room = newRoom {
                try projectFileManager.copyRoomFile(from: room, to: updatedProject)
            }
            
            // Save updated metadata
            try projectFileManager.saveProjectMetadata(updatedProject)
            
            // Update in array
            if let index = projects.firstIndex(where: { $0.id == project.id }) {
                projects[index] = updatedProject
            }
            
            print("🏠 Successfully updated room for project: \(project.displayName)")
            
        } catch {
            print("❌ Failed to update project room: \(error)")
            errorMessage = "Failed to update project room: \(error.localizedDescription)"
        }
    }
    
    private func generateDefaultName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy 'at' HH:mm"
        return "Project \(formatter.string(from: Date()))"
    }
    
    private func generatePlaceholderThumbnail(for project: Project) -> UIImage? {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let colors = project.hasRoom ?
                [UIColor.systemOrange.withAlphaComponent(0.8), UIColor.systemOrange.withAlphaComponent(0.4)] :
                [UIColor.systemGray.withAlphaComponent(0.8), UIColor.systemGray.withAlphaComponent(0.4)]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: [colors[0].cgColor, colors[1].cgColor] as CFArray, locations: [0.0, 1.0])
            
            context.cgContext.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Add icon and text
            let icon = project.hasRoom ? "house.fill" : "folder.fill"
            let iconConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
            let iconImage = UIImage(systemName: icon, withConfiguration: iconConfig)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            
            if let icon = iconImage {
                let iconRect = CGRect(x: (size.width - 40) / 2, y: (size.height - 40) / 2 - 20, width: 40, height: 40)
                icon.draw(in: iconRect)
            }
            
            // Add project name
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let text = project.displayName
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(x: (size.width - textSize.width) / 2, y: size.height - 30, width: textSize.width, height: textSize.height)
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    func refreshData() {
        loadProjects()
    }
    
    func getRoomById(_ roomId: String?) -> RoomCaptured? {
        guard let roomId = roomId else { return nil }
        return availableRooms.first { $0.id.uuidString == roomId }
    }
    
    func getProjectStats() -> (total: Int, withRooms: Int, withoutRooms: Int) {
        let total = projects.count
        let withRooms = projects.filter { $0.hasRoom }.count
        let withoutRooms = total - withRooms
        return (total, withRooms, withoutRooms)
    }
    
    func getDataSourceStats() -> (fileSystemRooms: Int, bundleRooms: Int, fileSystemObjects: Int, bundleObjects: Int) {
        let fileSystemRooms = availableRooms.filter { $0.localURL != nil }.count
        let bundleRooms = availableRooms.filter { $0.localURL == nil }.count
        let fileSystemObjects = availableObjects.filter { $0.localURL != nil }.count
        let bundleObjects = availableObjects.filter { $0.localURL == nil }.count
        
        return (fileSystemRooms, bundleRooms, fileSystemObjects, bundleObjects)
    }
    
    func getStorageInfo() -> String {
        return projectFileManager.getProjectsDirectorySize()
    }
    
    func clearErrorMessage() {
        errorMessage = nil
    }
}

