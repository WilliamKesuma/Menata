//
//  CreateProjectSheet.swift
//  Menata
//
//  Created by Muhamad Azis on 18/06/25.
//

import SwiftUI

struct CreateProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var projectName: String = ""
    @State private var selectedRoom: RoomCaptured?
    
    let availableRooms: [RoomCaptured]
    let onCreateProject: (String, RoomCaptured?) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CreateProjectHeader()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ProjectNameSection(projectName: $projectName)
                        
                        RoomSelectionSection(
                            availableRooms: availableRooms,
                            selectedRoom: $selectedRoom
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Create Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CreateProjectToolbar(
                    selectedRoom: selectedRoom,
                    onCancel: { dismiss() },
                    onCreate: {
                        onCreateProject(projectName, selectedRoom)
                        dismiss()
                    }
                )
            }
        }
    }
}

struct CreateProjectHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Project")
                .font(.title3.bold())
            
            Text("Select a room to create your AR project")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
    }
}

struct ProjectNameSection: View {
    @Binding var projectName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Project Name (Optional)")
                .font(.headline)
            
            TextField("Enter project name", text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.done)
            
            Text("If left empty, a default name will be generated")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RoomSelectionSection: View {
    let availableRooms: [RoomCaptured]
    @Binding var selectedRoom: RoomCaptured?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Room for Project")
                .font(.headline)
            
            if availableRooms.isEmpty {
                RoomEmptyStateView()
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(availableRooms, id: \.id) { room in
                        RoomSelectionCard(
                            room: room,
                            isSelected: selectedRoom?.id == room.id
                        ) {
                            selectedRoom = room
                        }
                    }
                }
            }
        }
    }
}

struct RoomSelectionCard: View {
    let room: RoomCaptured
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(height: 80)
                    
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("3D")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                }
                
                VStack(spacing: 2) {
                    Text(room.name)
                        .font(.caption.bold())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(room.fileName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(room.fileSize)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.1), radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct RoomEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "house")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No Rooms Available")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Capture some rooms first to create projects")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Go to Home tab and scan Room1.usdz or Room.usdz")
                .font(.caption)
                .foregroundColor(.orange)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CreateProjectToolbar: ToolbarContent {
    let selectedRoom: RoomCaptured?
    let onCancel: () -> Void
    let onCreate: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel", action: onCancel)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Create", action: onCreate)
                .disabled(selectedRoom == nil)
        }
    }
}

#Preview {
    CreateProjectSheet(
        availableRooms: RoomCaptured.availableRooms,
        onCreateProject: { _, _ in }
    )
}
