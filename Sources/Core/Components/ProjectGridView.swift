//
//  ProjectGridView.swift
//  Menata
//
//  Created by Muhamad Azis on 18/06/25.
//

import SwiftUI

struct ProjectGridView: View {
    let projects: [Project]
    let availableRooms: [RoomCaptured]
    let onProjectTapped: (Project) -> Void
    let onDeleteProject: (Project) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(projects) { project in
                    ProjectCard(
                        project: project,
                        room: getRoomForProject(project)
                    ) {
                        onProjectTapped(project)
                    } onDelete: {
                        onDeleteProject(project)
                    }
                }
            }
            .padding()
        }
    }
    
    private func getRoomForProject(_ project: Project) -> RoomCaptured? {
        let room = project.selectedRoom
        print("🔍 ProjectGridView: Getting room for project '\(project.displayName)': \(room?.name ?? "nil")")
        return room
    }
}

struct ProjectCard: View {
    let project: Project
    let room: RoomCaptured?
    let onTap: () -> Void
    let onDelete: () -> Void
    
    // Helper function to get all USDZ files in assets directory
    private func getAssetFiles() -> [String] {
        guard let assetsDir = project.assetsDirectoryURL else { return [] }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: assetsDir.path)
            return files.filter { $0.hasSuffix(".usdz") }
        } catch {
            print("❌ Error reading assets directory: \(error)")
            return []
        }
    }
    
    // Helper function to check if any USDZ asset file exists in project
    private func hasAssetFile() -> Bool {
        return !getAssetFiles().isEmpty
    }
    
    // Helper function to get the first asset file name (without extension)
    private func getAssetFileName() -> String? {
        let assetFiles = getAssetFiles()
        guard let firstFile = assetFiles.first else { return nil }
        
        // Remove .usdz extension
        return String(firstFile.dropLast(5))
    }
    
    // Helper function to get asset file info
    private func getAssetFileInfo() -> (name: String, size: String, date: Date)? {
        guard let assetsDir = project.assetsDirectoryURL,
              let assetFileName = getAssetFiles().first else { return nil }
        
        let assetURL = assetsDir.appendingPathComponent(assetFileName)
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: assetURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            let modificationDate = attributes[.modificationDate] as? Date ?? Date()
            
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useMB]
            formatter.countStyle = .file
            let sizeString = formatter.string(fromByteCount: fileSize)
            
            return (name: String(assetFileName.dropLast(5)), size: sizeString, date: modificationDate)
        } catch {
            print("❌ Error getting file attributes: \(error)")
            return nil
        }
    }
    
    // Helper function to determine room name to display
    private func getRoomDisplayName() -> String {
        // Priority 1: If selectedRoom exists, use its name
        if let selectedRoom = project.selectedRoom {
            return selectedRoom.name
        }
        
        // Priority 2: If asset file exists, use asset filename
        if let assetFileName = getAssetFileName() {
            return assetFileName
        }
        
        // Priority 3: No room
        return "No Room"
    }
    
    // Helper function to determine the status
    private func getProjectStatus() -> ProjectStatus {
        let hasAsset = hasAssetFile()
        let hasSelectedRoom = project.selectedRoom != nil
        
        if hasAsset {
            return .assetReady
        } else if hasSelectedRoom {
            return .roomSelectedNotCopied
        } else {
            return .noRoom
        }
    }
    
    enum ProjectStatus {
        case assetReady
        case roomSelectedNotCopied
        case noRoom
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                ProjectThumbnailView(
                    project: project,
                    room: room,
                    status: getProjectStatus(),
                    displayName: getRoomDisplayName(),
                    assetInfo: getAssetFileInfo()
                )
                
                ProjectCardInfo(
                    project: project,
                    room: room,
                    status: getProjectStatus(),
                    displayName: getRoomDisplayName(),
                    assetInfo: getAssetFileInfo()
                )
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            ProjectContextMenu(
                project: project,
                onEdit: onTap,
                onDelete: onDelete
            )
        }
    }
    
    struct ProjectContextMenu: View {
        let project: Project
        let onEdit: () -> Void
        let onDelete: () -> Void
        
        var body: some View {
            Button(action: onEdit) {
                Label("Open Project", systemImage: "arrow.right.circle")
            }
            
            Button(action: onEdit) {
                Label("Edit Project", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive, action: onDelete) {
                Label("Delete Project", systemImage: "trash")
            }
        }
    }
    
    struct ProjectThumbnailView: View {
        let project: Project
        let room: RoomCaptured?
        let status: ProjectCard.ProjectStatus
        let displayName: String
        let assetInfo: (name: String, size: String, date: Date)?
        
        private var gradientColors: [Color] {
            switch status {
            case .assetReady:
                return [Color.green.opacity(0.8), Color.green.opacity(0.4)]
            case .roomSelectedNotCopied:
                return [Color.orange.opacity(0.8), Color.orange.opacity(0.4)]
            case .noRoom:
                return [Color.gray.opacity(0.8), Color.gray.opacity(0.4)]
            }
        }

        private var roomSourceIndicator: some View {
            Group {
                switch status {
                case .assetReady:
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                        
                        Text("Asset Ready")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.9))
                    .cornerRadius(6)
                    
                case .roomSelectedNotCopied:
                    HStack(spacing: 2) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                        
                        Text("Pending Copy")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.9))
                    .cornerRadius(6)
                    
                case .noRoom:
                    HStack(spacing: 2) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                        
                        Text("No Room")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.9))
                    .cornerRadius(6)
                }
            }
        }
        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 120)
                
                VStack(spacing: 8) {
                    switch status {
                    case .assetReady:
                        Image(systemName: "cube.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text(displayName)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)
                            
                    case .roomSelectedNotCopied:
                        Image(systemName: "cube")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text(displayName)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .lineLimit(1)
                            
                    case .noRoom:
                        Image(systemName: "folder")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("No Room Selected")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                VStack {
                    HStack {
                        roomSourceIndicator
                        Spacer()
                    }
                    .padding(8)
                    
                    Spacer()
                }
            }
        }
    }
    
    struct ProjectCardInfo: View {
        let project: Project
        let room: RoomCaptured?
        let status: ProjectCard.ProjectStatus
        let displayName: String
        let assetInfo: (name: String, size: String, date: Date)?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                // PROJECT NAME & STATUS
                HStack {
                    Text(project.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                }
                
                // DATE AND FILE INFO
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text(project.createdDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
//                    if project.projectFolderPath != nil {
//                        HStack(spacing: 2) {
//                            Image(systemName: "folder.fill")
//                                .font(.caption2)
//                                .foregroundColor(.blue)
//
//                            Text("Saved")
//                                .font(.caption2)
//                                .foregroundColor(.blue)
//                        }
//                    }
                }
                
                // ASSET AND STATUS INFO
                switch status {
                case .assetReady:
                    if let assetInfo = assetInfo {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: "cube.fill")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                
                                Text("Asset: \(assetInfo.name)")
                                    .font(.caption2.bold())
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(assetInfo.size)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                case .roomSelectedNotCopied:
                    if let room = project.selectedRoom {
                        VStack(spacing: 4) {
                            HStack {
                                Image(systemName: "cube")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                
                                Text("Room: \(room.name)")
                                    .font(.caption2.bold())
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(room.fileSize)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                
                                Text("Asset not copied yet")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                
                                Spacer()
                                
                                Text("Action Required")
                                    .font(.caption2.bold())
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                case .noRoom:
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(.red)
                        
                        Text("No room selected")
                            .font(.caption2)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Text("Incomplete")
                            .font(.caption2.bold())
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

#Preview {
    ProjectGridView(
        projects: [],
        availableRooms: RoomCaptured.availableRooms,
        onProjectTapped: { _ in },
        onDeleteProject: { _ in }
    )
}
