//
//  USDAExportView.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import SwiftUI
import RealityKit

struct USDAExportView: View {
    let objects: [Entity]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Export Scene to USDZ")
                    .font(.title)
                    .padding()
                
                Text("This will export all placed objects as a USDZ file.")
                    .padding()
                
                Button("Export") {
//                    exportScene()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
//    private func exportScene() {
//        // Create a scene for export
//        let exportScene = Scene()
//        let exportAnchor = AnchorEntity()
//        
//        // Add all objects to export scene
//        for object in objects {
//            if let modelEntity = object as? ModelEntity {
//                let clonedEntity = modelEntity.clone(recursive: true)
//                exportAnchor.addChild(clonedEntity)
//            }
//        }
//        
//        exportScene.addAnchor(exportAnchor)
//        
//        // Create export URL
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let exportURL = documentsPath.appendingPathComponent("exported_scene_\(Date().timeIntervalSince1970).usdz")
//        
//        do {
//            // Export the scene
//            try exportScene.write(to: exportURL)
//            
//            // Present activity controller for sharing
//            DispatchQueue.main.async {
//                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let window = windowScene.windows.first,
//                   let rootVC = window.rootViewController {
//                    
//                    let activityVC = UIActivityViewController(activityItems: [exportURL], applicationActivities: nil)
//                    
//                    // For iPad
//                    if let popover = activityVC.popoverPresentationController {
//                        popover.sourceView = window
//                        popover.sourceRect = CGRect(x: window.frame.midX, y: window.frame.midY, width: 0, height: 0)
//                    }
//                    
//                    rootVC.present(activityVC, animated: true)
//                }
//            }
//            
//            dismiss()
//        } catch {
//            print("Error exporting USDZ: \(error)")
//        }
//    }
}

#Preview {
    USDAExportView(objects: [])
}
