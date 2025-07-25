//
//  StartingOverlayView.swift
//
//
//  Created by 日野森寛也 on 2024/04/12.
//

import SwiftUI

public struct StartingOverlayView: View {
    let centerHandler: @Sendable () async -> Void
    let dismissAction: () -> Void
    
    public init(
        centerHandler: @escaping @Sendable () async -> Void,
        dismissAction: @escaping () -> Void
    ) {
        self.centerHandler = centerHandler
        self.dismissAction = dismissAction
    }

    public var body: some View {
        VStack {
            // Header dengan tombol cancel di kiri atas
            HStack {
                Button(action: dismissAction) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(.leading, 20)
                .padding(.top, 20)
                
                Spacer()
            }
            
            Spacer()
            
            // Tombol detecting di tengah bawah
            HStack(alignment: .bottom) {
                Spacer()
                Button(
                    action: {
                        Task { await centerHandler() }
                    },
                    label: {
                        Text("Detecting")
                    })
                .buttonStyle(CapsuleButtonStyle())
                Spacer()
            }
        }
    }
}

#Preview {
    StartingOverlayView(
        centerHandler: { },
        dismissAction: { }
    )
}
