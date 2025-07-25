//
//  ProjectEmptyStateView.swift
//  Menata
//
//  Created by Muhamad Azis on 18/06/25.
//

import SwiftUI

struct ProjectEmptyStateView: View {
    let onAddNewProject: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "folder")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                VStack(spacing: 8) {
                    Text("No Projects Yet")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Create your first project to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Rooms:")
                        .font(.caption.bold())
                        .foregroundColor(.primary)
                    
                    let availableRooms = RoomCaptured.availableRooms.filter { $0.isAvailable }
                    
                    if availableRooms.isEmpty {
                        Text("No rooms captured yet. Capture rooms first.")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(availableRooms, id: \.id) { room in
                                Text("• \(room.name) (\(room.fileSize))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button(action: onAddNewProject) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create Project")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(25)
                }
                .disabled(RoomCaptured.availableRooms.filter { $0.isAvailable }.isEmpty)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ProjectEmptyStateView(onAddNewProject: {})
}
