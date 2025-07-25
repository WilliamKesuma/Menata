//
//  ProjectLoadingView.swift
//  Menata
//
//  Created by Muhamad Azis on 18/06/25.
//

import SwiftUI

struct ProjectLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    .scaleEffect(1.2)
                
                Text("Loading Projects...")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Preparing your workspace")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProjectLoadingView()
}
