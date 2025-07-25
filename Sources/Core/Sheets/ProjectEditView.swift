//
//  ProjectEditView.swift
//  Menata
//
//  Created by Muhamad Azis on 19/06/25.
//

import SwiftUI

// MARK: - Supporting Types
enum RoomSource {
    case captured
    case sample
}

struct ProjectEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var editedProject: Project
    @State private var showingDeleteAlert = false
    @State private var showCombineView = false
    @State private var showingRoomSelector = false
    
    let onSave: (Project) -> Void
    let onUpdateRoom: (Project, RoomCaptured?) -> Void
    let onDelete: (Project) -> Void
    
    // Available rooms for selection
    private var availableRooms: [RoomCaptured] {
        RoomCaptured.availableRooms.filter { $0.isAvailable }
    }
    
    // Helper functions for asset management
    private func getAssetFiles() -> [String] {
        guard let assetsDir = editedProject.assetsDirectoryURL else { return [] }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: assetsDir.path)
            return files.filter { $0.hasSuffix(".usdz") }
        } catch {
            print("❌ Error reading assets directory: \(error)")
            return []
        }
    }
    
    private func hasAssetFile() -> Bool {
        return !getAssetFiles().isEmpty
    }
    
    private func getAssetFileName() -> String? {
        let assetFiles = getAssetFiles()
        guard let firstFile = assetFiles.first else { return nil }
        return String(firstFile.dropLast(5)) // Remove .usdz extension
    }
    
    private func getAssetFileInfo() -> (name: String, size: String, date: Date)? {
        guard let assetsDir = editedProject.assetsDirectoryURL,
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
    
    private func getRoomDisplayName() -> String {
        // Priority 1: If selectedRoom exists, use its name
        if let selectedRoom = editedProject.selectedRoom {
            return selectedRoom.name
        }
        
        // Priority 2: If asset file exists, use asset filename
        if let assetFileName = getAssetFileName() {
            return assetFileName
        }
        
        // Priority 3: No room
        return "No Room"
    }
    
    private func getProjectStatus() -> ProjectStatus {
        let hasAsset = hasAssetFile()
        let hasSelectedRoom = editedProject.selectedRoom != nil
        
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
        
        var displayText: String {
            switch self {
            case .assetReady: return "Asset Ready"
            case .roomSelectedNotCopied: return "Pending Copy"
            case .noRoom: return "No Room"
            }
        }
        
        var systemIcon: String {
            switch self {
            case .assetReady: return "checkmark.circle.fill"
            case .roomSelectedNotCopied: return "clock.fill"
            case .noRoom: return "exclamationmark.triangle.fill"
            }
        }
        
        var colors: [Color] {
            switch self {
            case .assetReady: return [Color.green.opacity(0.8), Color.green.opacity(0.4)]
            case .roomSelectedNotCopied: return [Color.orange.opacity(0.8), Color.orange.opacity(0.4)]
            case .noRoom: return [Color.gray.opacity(0.8), Color.gray.opacity(0.4)]
            }
        }
        
        var indicatorColor: Color {
            switch self {
            case .assetReady: return .green
            case .roomSelectedNotCopied: return .orange
            case .noRoom: return .red
            }
        }
    }
    
    init(project: Project,
         onSave: @escaping (Project) -> Void,
         onUpdateRoom: @escaping (Project, RoomCaptured?) -> Void = { _, _ in },
         onDelete: @escaping (Project) -> Void = { _ in }) {
        self._editedProject = State(initialValue: project)
        self.onSave = onSave
        self.onUpdateRoom = onUpdateRoom
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack(spacing: 20) {
                        ProjectThumbnailSection(
                            project: editedProject,
                            status: getProjectStatus(),
                            displayName: getRoomDisplayName(),
                            assetInfo: getAssetFileInfo()
                        )
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ProjectNameEditSection(projectName: $editedProject.name)
                            
                            ProjectInfoSection(
                                project: editedProject,
                                status: getProjectStatus(),
                                assetInfo: getAssetFileInfo()
                            )
                            
                            // Continue Edit Button
                            Button(
                                action: {
                                    showCombineView = true
                                },
                                label: {
                                    HStack {
                                        Image(systemName: "arkit")
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Continue to AR Editor")
                                                .fontWeight(.semibold)
                                            
                                            Text("Project is \(getProjectStatus().displayText.lowercased())")
                                                .font(.caption)
                                                .opacity(0.8)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(getProjectStatus().indicatorColor)
                                    .cornerRadius(12)
                                }
                            )
                            
                            Spacer()
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .navigationTitle("Edit Project")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ProjectEditToolbar(
                        onCancel: { dismiss() },
                        onSave: {
                            onSave(editedProject)
                            dismiss()
                        },
                        onDelete: {
                            showingDeleteAlert = true
                        }
                    )
                }
            }
        }
        .alert("Delete Project", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete(editedProject)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(editedProject.displayName)'?\n\nThis will permanently delete all project files.\n\nThis action cannot be undone.")
        }
        .sheet(isPresented: $showingRoomSelector) {
            RoomSelectorSheet(
                availableRooms: availableRooms,
                currentRoom: editedProject.selectedRoom
            ) { selectedRoom in
                // Update the room and notify parent
                editedProject.selectedRoom = selectedRoom
                onUpdateRoom(editedProject, selectedRoom)
            }
        }
        .fullScreenCover(isPresented: $showCombineView) {
            CanvasView(isPresented:  $showCombineView)
        }
    }
}

struct ProjectThumbnailSection: View {
    let project: Project
    let status: ProjectEditView.ProjectStatus
    let displayName: String
    let assetInfo: (name: String, size: String, date: Date)?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: status.colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 200)
            
            VStack(spacing: 12) {
                switch status {
                case .assetReady:
                    Image(systemName: "cube.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text(displayName)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    if let assetInfo = assetInfo {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Text("Asset Ready • \(assetInfo.size)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.7))
                        .cornerRadius(12)
                    }
                    
                case .roomSelectedNotCopied:
                    if let room = project.selectedRoom {
                        Image(systemName: "cube")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text(room.name)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Text("Asset Not Copied Yet")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.7))
                        .cornerRadius(12)
                    }
                    
                case .noRoom:
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("No Room Selected")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text("Select a room to start")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Project status indicator
            VStack {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: status.systemIcon)
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Text(status.displayText)
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status.indicatorColor.opacity(0.8))
                    .cornerRadius(8)
                }
                .padding(12)
                
                Spacer()
            }
        }
        .padding()
    }
}

struct ProjectNameEditSection: View {
    @Binding var projectName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Project Name")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Enter project name", text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.return)
            
            if projectName.isEmpty {
                Text("Project name cannot be empty")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}

struct ProjectInfoSection: View {
    let project: Project
    let status: ProjectEditView.ProjectStatus
    let assetInfo: (name: String, size: String, date: Date)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                InfoRow(
                    title: "Created",
                    value: project.createdDate.formatted(date: .abbreviated, time: .shortened)
                )
                
                InfoRow(
                    title: "Last Modified",
                    value: project.lastModified.formatted(date: .abbreviated, time: .shortened)
                )
                
                InfoRow(
                    title: "Project ID",
                    value: project.id.uuidString.prefix(8).uppercased() + "...",
                    valueColor: .secondary
                )
                
                Divider()
                
                switch status {
                case .assetReady:
                    if let assetInfo = assetInfo {
                        InfoRow(title: "Asset Name", value: "\(assetInfo.name).usdz", valueColor: .primary)
                        InfoRow(title: "Asset Size", value: assetInfo.size, valueColor: .secondary)
                        InfoRow(title: "Asset Status", value: "Ready for AR", valueColor: .green)
                        InfoRow(title: "Asset Date", value: assetInfo.date.formatted(date: .abbreviated, time: .omitted), valueColor: .secondary)
                    }
                    
                case .roomSelectedNotCopied:
                    if let room = project.selectedRoom {
                        InfoRow(title: "Room Name", value: room.name, valueColor: .primary)
                        InfoRow(title: "Room File", value: "\(room.usdzFileName).usdz", valueColor: .secondary)
                        InfoRow(title: "File Size", value: room.fileSize, valueColor: .secondary)
                        InfoRow(title: "Room Source", value: room.localURL != nil ? "Captured (File System)" : "Sample (Bundle)", valueColor: room.localURL != nil ? .green : .blue)
                        InfoRow(title: "Room Captured", value: room.captureDate.formatted(date: .abbreviated, time: .omitted), valueColor: .secondary)
                        InfoRow(title: "Copy Status", value: "Pending - Asset not copied", valueColor: .orange)
                    }
                    
                case .noRoom:
                    InfoRow(title: "Room", value: "Not selected", valueColor: .red)
                    InfoRow(title: "Asset", value: "None", valueColor: .red)
                    InfoRow(title: "Status", value: "Incomplete - Room required", valueColor: .red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RoomSelectorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRoom: RoomCaptured?
    
    let availableRooms: [RoomCaptured]
    let currentRoom: RoomCaptured?
    let onRoomSelected: (RoomCaptured?) -> Void
    
    private var fileSystemRooms: [RoomCaptured] {
        availableRooms.filter { $0.localURL != nil }
    }
    
    private var bundleRooms: [RoomCaptured] {
        availableRooms.filter { $0.localURL == nil }
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(availableRooms: [RoomCaptured], currentRoom: RoomCaptured?, onRoomSelected: @escaping (RoomCaptured?) -> Void) {
        self.availableRooms = availableRooms
        self.currentRoom = currentRoom
        self.onRoomSelected = onRoomSelected
        self._selectedRoom = State(initialValue: currentRoom)
    }
    
    // MARK: - Helper Methods
    private func selectRoom(_ room: RoomCaptured) {
        selectedRoom = room
    }
    
    private func removeRoomSelection() {
        selectedRoom = nil
    }
    
    private func isRoomSelected(_ room: RoomCaptured) -> Bool {
        return selectedRoom?.id == room.id
    }
    
    // MARK: - Views
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Change Room")
                .font(.title3.bold())
            
            Text("Select a different room for this project")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            roomCountsView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var roomCountsView: some View {
        HStack(spacing: 16) {
            capturedRoomCount
            sampleRoomCount
            Spacer()
        }
    }
    
    private var capturedRoomCount: some View {
        HStack(spacing: 4) {
            Image(systemName: "externaldrive.fill")
                .font(.caption2)
                .foregroundColor(.green)
            Text("\(fileSystemRooms.count) Captured")
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
    
    private var sampleRoomCount: some View {
        HStack(spacing: 4) {
            Image(systemName: "app.badge")
                .font(.caption2)
                .foregroundColor(.blue)
            Text("\(bundleRooms.count) Samples")
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
    
    private var removeRoomSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Remove Room")
                .font(.subheadline.bold())
                .foregroundColor(.primary)
            
            removeRoomButton
        }
    }
    
    private var removeRoomButton: some View {
        Button(action: removeRoomSelection) {
            HStack {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                
                Text("No Room (Remove current selection)")
                    .foregroundColor(.primary)
                
                Spacer()
                
                if selectedRoom == nil {
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedRoom == nil ? Color.orange : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func capturedRoomsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            capturedRoomsHeader
            capturedRoomsGrid
        }
    }
    
    private var capturedRoomsHeader: some View {
        HStack {
            Image(systemName: "externaldrive.fill")
                .font(.caption)
                .foregroundColor(.green)
            
            Text("Captured Rooms (\(fileSystemRooms.count))")
                .font(.subheadline.bold())
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private var capturedRoomsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(fileSystemRooms, id: \.id) { room in
                createRoomCard(room: room, source: .captured)
            }
        }
    }
    
    private func sampleRoomsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sampleRoomsHeader
            sampleRoomsGrid
        }
    }
    
    private var sampleRoomsHeader: some View {
        HStack {
            Image(systemName: "app.badge")
                .font(.caption)
                .foregroundColor(.blue)
            
            Text("Sample Rooms (\(bundleRooms.count))")
                .font(.subheadline.bold())
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
    
    private var sampleRoomsGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(bundleRooms, id: \.id) { room in
                createRoomCard(room: room, source: .sample)
            }
        }
    }
    
    private func createRoomCard(room: RoomCaptured, source: RoomSource) -> some View {
        RoomSelectionCard(
            room: room,
            isSelected: isRoomSelected(room),
            onTap: {
                selectRoom(room)
            }
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 20) {
                        removeRoomSection
                        
                        if !fileSystemRooms.isEmpty {
                            capturedRoomsSection()
                        }
                        
                        if !bundleRooms.isEmpty {
                            sampleRoomsSection()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onRoomSelected(selectedRoom)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let valueColor: Color
    
    init(title: String, value: String, valueColor: Color = .secondary) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct ProjectEditToolbar: ToolbarContent {
    let onCancel: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: onCancel)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                Button("Delete", action: onDelete)
                    .foregroundColor(.red)
                    .font(.subheadline)
                
                Button("Save", action: onSave)
                    .fontWeight(.semibold)
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    ProjectEditView(
        project: Project(name: "Sample Project", selectedRoom: RoomCaptured.availableRooms.first),
        onSave: { _ in print("Project saved") },
        onUpdateRoom: { _, _ in print("Room updated") },
        onDelete: { _ in print("Project deleted") }
    )
}
