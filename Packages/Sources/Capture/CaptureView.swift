//
//  CaptureView.swift
//
//
//  Created by 日野森寛也 on 2024/04/09.
//  Edited by Muhamad Azis pm 2025/06/24
//

import SwiftUI
import RealityKit
import Common

public struct CaptureView: View {
    @State var model: CapturingModel
    let onDismiss: () -> Void // Tambahkan parameter untuk kembali ke ScannerView
    
    public init(model: CapturingModel, onDismiss: @escaping () -> Void) {
        self.model = model
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            ObjectCaptureView(session: model.objectCaptureSession)
                .ignoresSafeArea()
                .id(model.objectCaptureSession.id)
                .overlay {
                    if model.isShowOverlay {
                        switch model.state {
                        case .start:
                            StartingOverlayView(
                                centerHandler: { await model.startDetection() },
                                dismissAction: {
                                    model.cancel()
                                    onDismiss() // Kembali ke ScannerView
                                }
                            )
                        case .detecting:
                            DetectingOverlayView { await model.startCapture() } cancelHandler: { await model.cancel() }
                        case .capturing:
                            CapturingOverlayView { await model.cancel() }
                        case .finish:
                            FinishedOverlayView {
                                await model.beginNewScanPass()
                            } middleButtonHandler: {
                                await model.beginNewScanPassAfterFlip()
                            } bottomButtonHandler: {
                                await model.finishCapture()
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
        }
        .alert(isPresented: .init(get: {
            model.state == .failed
        }, set: { _ in }), content: {
            Alert(
                title: .init("Something Error!!!!"),
                dismissButton: .destructive(.init("OK"), action: {
                    model.cancel()
                    onDismiss() // Kembali ke ScannerView saat error
                })
            )
        })
    }
}
