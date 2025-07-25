//
//  ProjectView.swift
//  Menata
//
//  Created by Muhamad Azis on 16/06/25.
//

import SwiftUI

struct ProjectView: View {
    @StateObject private var viewModel = ProjectViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            ProjectHeaderView {
                viewModel.showingCreateProject = true
            }
            
            mainContentView
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $viewModel.showingCreateProject) {
            CreateProjectSheet(
                availableRooms: viewModel.availableRooms
            ) { name, room in
                viewModel.createProject(name: name, selectedRoom: room)
            }
        }
        .sheet(item: $viewModel.selectedProject) { project in
            ProjectEditView(
                project: project,
                onSave: { updatedProject in
                    viewModel.updateProject(updatedProject)
                },
                onDelete: { projectToDelete in
                    viewModel.deleteProject(projectToDelete)
                }
            )
        }
        .refreshable {
            viewModel.refreshData()
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        if viewModel.isLoading {
            ProjectLoadingView()
        } else if viewModel.projects.isEmpty {
            ProjectEmptyStateView {
                viewModel.showingCreateProject = true
            }
        } else {
            VStack(spacing: 0) {
                // Stats Section
                projectStatsView
                
                ProjectGridView(
                    projects: viewModel.projects,
                    availableRooms: viewModel.availableRooms
                ) { project in
                    viewModel.selectedProject = project
                } onDeleteProject: { project in
                    viewModel.deleteProject(project)
                }
            }
        }
    }
    
    private var projectStatsView: some View {
        VStack(spacing: 8) {
            let stats = viewModel.getProjectStats()
            let dataStats = viewModel.getDataSourceStats()
            
            HStack {
                Image(systemName: "folder.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Projects: \(stats.total)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button("Refresh") {
                    viewModel.refreshData()
                }
                .font(.caption)
                .foregroundColor(.orange)
            }
            
            // Data source info
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "externaldrive.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("Captured Rooms: \(dataStats.fileSystemRooms)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "app.badge")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("Sample Rooms: \(dataStats.bundleRooms)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
}

#Preview {
    ProjectView()
}
