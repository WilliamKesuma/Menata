//
//  RoomGridView.swift
//  Menata
//
//  Created by Muhamad Azis on 17/06/25.
//

import SwiftUI
import QuickLook

struct RoomGridView: View {
    let rooms: [RoomCaptured]
    let onRoomDeleted: (() -> Void)?
    
    @State private var selectedRoom: RoomCaptured?
    @State private var showingPreview = false
    @State private var showingDeleteAlert = false
    @State private var roomToDelete: RoomCaptured?
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    init(rooms: [RoomCaptured], onRoomDeleted: (() -> Void)? = nil) {
        self.rooms = rooms
        self.onRoomDeleted = onRoomDeleted
    }
    
    var body: some View {
        ScrollView {
            if rooms.isEmpty {
                EmptyRoomsView()
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(rooms, id: \.id) { room in
                        RoomCard(room: room) {
                            selectedRoom = room
                            showingPreview = true
                        } onDelete: {
                            roomToDelete = room
                            showingDeleteAlert = true
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let room = selectedRoom, let usdzURL = room.usdzURL {
                ARPreviewSheet(url: usdzURL, title: room.name)
            }
        }
        .alert("Delete Room", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let room = roomToDelete {
                    deleteRoom(room)
                }
            }
        } message: {
            if let room = roomToDelete {
                if room.localURL != nil {
                    Text("Are you sure you want to delete '\(room.name)'? This action cannot be undone.")
                } else {
                    Text("Cannot delete '\(room.name)' because it's a bundle resource.")
                }
            }
        }
    }
    
    private func deleteRoom(_ room: RoomCaptured) {
        guard let localURL = room.localURL else {
            print("❌ Cannot delete bundle resource: \(room.name)")
            return
        }
        
        do {
            try FileSystemManager.shared.deleteFile(at: localURL)
            onRoomDeleted?() // Notify parent to refresh
            print("✅ Successfully deleted room: \(room.name)")
        } catch {
            print("Failed to delete room: \(error.localizedDescription)")
        }
    }
}

struct RoomCard: View {
    let room: RoomCaptured
    let onTap: () -> Void
    let onDelete: () -> Void
    
    private var canDelete: Bool {
        room.localURL != nil // Hanya bisa delete file dari file system, bukan bundle
    }
    
    private var sourceIndicator: some View {
        HStack {
            Image(systemName: room.localURL != nil ? "externaldrive.fill" : "app.badge")
                .font(.caption2)
                .foregroundColor(.white)
            
            Text(room.localURL != nil ? "Captured" : "Sample")
                .font(.caption2.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(room.localURL != nil ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
        .cornerRadius(8)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.orange.opacity(0.8), .orange.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 100)
                    
                    VStack {
                        Image(systemName: "house.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Text("3D Room")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    
                    // Source indicator and menu
                    VStack {
                        HStack {
                            sourceIndicator
                            Spacer()
                            
                            Menu {
                                Button(action: onTap) {
                                    Label("Preview", systemImage: "eye")
                                }
                                
                                if canDelete {
                                    Button(role: .destructive, action: onDelete) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                } else {
                                    Button(action: {}) {
                                        Label("Cannot Delete Sample", systemImage: "lock")
                                    }
                                    .disabled(true)
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                        Spacer()
                    }
                    .padding(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(room.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(room.fileName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text(room.captureDate, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(room.fileSize)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyRoomsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Rooms Found")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("Start capturing rooms to see them here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Start Room Capture") {
                // Action untuk start room capture
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RoomGridView(rooms: RoomCaptured.availableRooms.filter { $0.isAvailable })
}
