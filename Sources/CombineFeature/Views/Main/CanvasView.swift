//
//  CanvasView.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import SwiftUI
import RealityKit

struct CanvasView: View {
    @State private var placedObjects: [Entity] = []
    @State private var showingExportSheet = false
    @Binding var isPresented: Bool  // Binding untuk mengontrol close
    
    var body: some View {
        ZStack {
            RealityKitCanvasView(placedObjects: $placedObjects)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    // Close button (X) di pojok kiri atas
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    .hoverEffect(.lift)  // Untuk iPad
                    
                    Spacer()
                    
                    // Export button
                    Button("Export USDZ") {
                        exportToUSDZ()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Object buttons di bawah
                HStack(spacing: 20) {
                    ObjectButton(icon: "chair.fill", objectName: "OCKursi") {
                        addObject(named: "OCKursi")
                    }
                    ObjectButton(icon: "table.fill", objectName: "OCKursiKotak") {
                        addObject(named: "OCKursiKotak")
                    }
                    ObjectButton(icon: "cube.fill", objectName: "Vanesh") {
                        addObject(named: "Vanesh")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            USDAExportView(objects: placedObjects)
        }
    }
    
    func addObject(named name: String) {
        // Try loading from bundle first, fallback to procedural generation
        if let model = try? ModelEntity.load(named: name) {
            model.generateCollisionShapes(recursive: true)
            model.name = name
            placedObjects.append(model)
        } else {
            // Fallback to procedural generation
            let entity = ObjectFactory.createProceduralModel(named: name)
            entity.name = name
            entity.generateCollisionShapes(recursive: true)
            placedObjects.append(entity)
        }
    }
    
    private func exportToUSDZ() {
        showingExportSheet = true
    }
}

// Preview dengan dummy binding
#Preview {
    CanvasView(isPresented: .constant(true))
}
