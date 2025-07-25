//
//  ObjectButton.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import SwiftUI

struct ObjectButton: View {
    let icon: String
    let objectName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                    .padding(10)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
                Text(objectName)
                    .font(.caption)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}

#Preview {
    ObjectButton(icon: "chair.fill", objectName: "OCKursi") {
        print("Button tapped")
    }
}
