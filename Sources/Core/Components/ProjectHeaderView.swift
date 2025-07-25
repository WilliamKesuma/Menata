//
//  ProjectHeaderView.swift
//  Menata
//
//  Created by Muhamad Azis on 17/06/25.
//

import SwiftUI

struct ProjectHeaderView: View {
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Project")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: onAddTapped) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                .accessibilityLabel("Add new project")
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 15)
        }
        .background(Color.orange)
    }
}

#Preview {
    ProjectHeaderView(onAddTapped: {})
}
