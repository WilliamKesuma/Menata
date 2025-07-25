//
//  HomeViewModel.swift
//  Menata
//
//  Created by Muhamad Azis on 17/06/25.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var rooms: [RoomCaptured] = []
    @Published var objects: [ObjectCaptured] = []
    @Published var isLoading = false
    @Published var selectedSegment = 0
    
    init() {
        loadCapturedData()
    }
    
    func loadCapturedData() {
        isLoading = true
        
        // Simulate loading time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loadAvailableRooms()
            self.loadAvailableObjects()
            self.isLoading = false
        }
    }
    
    private func loadAvailableRooms() {
        // Menggunakan static property yang sudah menggabungkan file system + bundle
        self.rooms = RoomCaptured.availableRooms.filter { $0.isAvailable }
        print("📁 Loaded \(self.rooms.count) rooms (FileSystem + Bundle)")
        
        // Debug: Print available room files
        for room in self.rooms {
            let source = room.localURL != nil ? "FileSystem" : "Bundle"
            print("✅ Room: \(room.name) - File: \(room.usdzFileName).usdz - Size: \(room.fileSize) - Source: \(source)")
        }
    }
    
    private func loadAvailableObjects() {
        // Menggunakan static property yang sudah menggabungkan file system + bundle
        self.objects = ObjectCaptured.availableObjects.filter { $0.isAvailable }
        print("🎯 Loaded \(self.objects.count) objects (FileSystem + Bundle)")
        
        // Debug: Print available object files
        for object in self.objects {
            let source = object.localURL != nil ? "FileSystem" : "Bundle"
            print("✅ Object: \(object.name) - File: \(object.usdzFileName).usdz - Size: \(object.fileSize) - Source: \(source)")
        }
    }
    
    func refreshData() {
        loadCapturedData()
    }
    
    func deleteRoom(_ room: RoomCaptured) {
        // Hanya bisa delete jika file ada di local storage
        guard let localURL = room.localURL else {
            print("❌ Cannot delete bundle resource: \(room.name)")
            return
        }
        
        do {
            try FileSystemManager.shared.deleteFile(at: localURL)
            refreshData() // Reload data setelah delete
        } catch {
            print("Failed to delete room: \(error.localizedDescription)")
        }
    }
    
    func deleteObject(_ object: ObjectCaptured) {
        // Hanya bisa delete jika file ada di local storage
        guard let localURL = object.localURL else {
            print("❌ Cannot delete bundle resource: \(object.name)")
            return
        }
        
        do {
            try FileSystemManager.shared.deleteFile(at: localURL)
            refreshData() // Reload data setelah delete
        } catch {
            print("Failed to delete object: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper Methods
    func getRoomCount() -> Int {
        return rooms.count
    }
    
    func getObjectCount() -> Int {
        return objects.count
    }
    
    func getFileSystemItemsCount() -> (rooms: Int, objects: Int) {
        let fileSystemRooms = rooms.filter { $0.localURL != nil }.count
        let fileSystemObjects = objects.filter { $0.localURL != nil }.count
        return (fileSystemRooms, fileSystemObjects)
    }
    
    func getBundleItemsCount() -> (rooms: Int, objects: Int) {
        let bundleRooms = rooms.filter { $0.localURL == nil }.count
        let bundleObjects = objects.filter { $0.localURL == nil }.count
        return (bundleRooms, bundleObjects)
    }
}
