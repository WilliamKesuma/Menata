//
//  ObjectGridView.swift
//  Menata
//
//  Created by Muhamad Azis on 17/06/25.
//

import SwiftUI
import QuickLook

struct ObjectGridView: View {
    let objects: [ObjectCaptured]
    let onObjectDeleted: (() -> Void)?
    
    @State private var selectedObject: ObjectCaptured?
    @State private var showingPreview = false
    @State private var showingDeleteAlert = false
    @State private var objectToDelete: ObjectCaptured?
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    init(objects: [ObjectCaptured], onObjectDeleted: (() -> Void)? = nil) {
        self.objects = objects
        self.onObjectDeleted = onObjectDeleted
    }
    
    var body: some View {
        ScrollView {
            if objects.isEmpty {
                EmptyObjectsView()
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(objects, id: \.id) { object in
                        ObjectCard(object: object) {
                            selectedObject = object
                            showingPreview = true
                        } onDelete: {
                            objectToDelete = object
                            showingDeleteAlert = true
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let object = selectedObject, let usdzURL = object.usdzURL {
                ARPreviewSheet(url: usdzURL, title: object.name)
            }
        }
        .alert("Delete Object", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let object = objectToDelete {
                    deleteObject(object)
                }
            }
        } message: {
            if let object = objectToDelete {
                if object.localURL != nil {
                    Text("Are you sure you want to delete '\(object.name)'? This action cannot be undone.")
                } else {
                    Text("Cannot delete '\(object.name)' because it's a bundle resource.")
                }
            }
        }
    }
    
    private func deleteObject(_ object: ObjectCaptured) {
        guard let localURL = object.localURL else {
            print("❌ Cannot delete bundle resource: \(object.name)")
            return
        }
        
        do {
            try FileSystemManager.shared.deleteFile(at: localURL)
            onObjectDeleted?() // Notify parent to refresh
            print("✅ Successfully deleted object: \(object.name)")
        } catch {
            print("Failed to delete object: \(error.localizedDescription)")
        }
    }
}

struct ObjectCard: View {
    let object: ObjectCaptured
    let onTap: () -> Void
    let onDelete: () -> Void
    
    private var canDelete: Bool {
        object.localURL != nil // Hanya bisa delete file dari file system, bukan bundle
    }
    
    private var sourceIndicator: some View {
        HStack {
            Image(systemName: object.localURL != nil ? "externaldrive.fill" : "app.badge")
                .font(.caption2)
                .foregroundColor(.white)
            
            Text(object.localURL != nil ? "Captured" : "Sample")
                .font(.caption2.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(object.localURL != nil ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
        .cornerRadius(8)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.8), .blue.opacity(0.5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 100)
                    
                    VStack {
                        Image(systemName: "cube.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        Text("3D Object")
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
                    Text(object.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(object.fileName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text(object.captureDate, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(object.fileSize)
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

struct EmptyObjectsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Objects Found")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("Start capturing objects to see them here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Start Object Capture") {
                // Action untuk start object capture
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ObjectGridView(objects: ObjectCaptured.availableObjects.filter { $0.isAvailable })
}


