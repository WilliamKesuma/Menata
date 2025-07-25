//
//  CombineHeaderView.swift
//  Menata
//
//  Created by Muhamad Azis on 20/06/25.
//

import SwiftUI

struct CombineHeaderView: View {
    let project: Project
    
    var body: some View {
        VStack {
            HStack {
                Text(project.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 15)
        }
        .background(Color.orange)
    }
}

//#Preview {
//    CombineHeaderView(project: Project.sampleProjects.first!)
//}

