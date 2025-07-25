//
//  ScannerView.swift
//  Menata
//
//  Created by Muhamad Azis on 16/06/25.
//

import SwiftUI
import App
import Capture
import Common
import FileBrowser
import Folder
import Reconstruction
import Viewer

struct ScannerView: View {
    @State private var isShowingRoomCaptureView = false
    @State private var isShowingObjectCaptureView = false
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Scanner")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 15)
            .background(Color.orange)
            
            Spacer()
            
            // Camera Preview Placeholder
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
                .frame(height: 300)
                .overlay(
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Camera Preview")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                    }
                )
                .padding(.horizontal)
            
            Spacer()
            
            // Scanner Options
            VStack(spacing: 20) {
                Button(action: {
                    isShowingRoomCaptureView = true
                }) {
                    HStack {
                        Image(systemName: "camera.metering.center.weighted")
                            .font(.title2)
                            .foregroundColor(.black)
                        Text("Room Plan Scanner")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                
                Button(action: {
                    isShowingObjectCaptureView = true
                }) {
                    HStack {
                        Image(systemName: "camera.metering.spot")
                            .font(.title2)
                            .foregroundColor(.black)
                        Text("Object Scanner")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGray6))
        .fullScreenCover(isPresented: $isShowingRoomCaptureView) {
            RoomCaptureViewWrapper()
        }
        .fullScreenCover(isPresented: $isShowingObjectCaptureView) {
            ObjectCaptureWrapper()
        }
    }
}

// Wrapper untuk Object Capture dalam fullscreen
struct ObjectCaptureWrapper: View {
    @Environment(\.dismiss) private var dismiss
    @State var isOpenFileView = false
    @State var selectedItemURL: URL?
    @State var isShowViewer = false
    @State var isReconstruction = false
    let captureModel: CapturingModel = .instance
    let folder = Folder()
    
    var body: some View {
        ZStack {
            if captureModel.isReadyToCapture {
                CaptureView(
                    model: captureModel,
                    onDismiss: {
                        // Reset model dan dismiss fullscreen
                        captureModel.reset()
                        dismiss()
                    }
                )
            } else {
                // Loading view dengan background hitam seperti kamera
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Initializing Camera...")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
            }
        }
        .overlay {
            FileOpenOverlayView { @MainActor in
                isOpenFileView = true
            }
        }
        .sheet(isPresented: $isOpenFileView) {
            DocumentBrowser(startingDir: folder.modelsFolder, selectedItem: $selectedItemURL)
        }
        .onChange(of: captureModel.isReadyToReconstruction == true, {
            isReconstruction = true
        })
        .sheet(isPresented: $isReconstruction, onDismiss: { @MainActor in
            captureModel.reset()
            dismiss() // Kembali ke scanner view setelah reconstruction
        }, content: {
            ReconstructionProgressView(model: .instance)
        })
        .onChange(of: selectedItemURL) {
            if selectedItemURL != nil {
                isShowViewer = true
            }
        }
        .sheet(isPresented: $isShowViewer, onDismiss: { @MainActor in
            captureModel.reset()
            dismiss() // Kembali ke scanner view setelah viewer
        }, content: {
            ModelViewer(url: selectedItemURL!)
        })
    }
}

#Preview {
    ScannerView()
}

