//
//  RoomSelectionRow.swift
//  Menata
//
//  Created by Muhamad Azis on 17/06/25.
//

import SwiftUI

struct RoomSelectionRow: View {
    let roomName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                RoomIcon(roomName: roomName)
                
                Text(roomName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

private struct RoomIcon: View {
    let roomName: String
    
    var body: some View {
        Image(systemName: iconName)
            .foregroundColor(.orange)
            .frame(width: 30)
    }
    
    private var iconName: String {
        switch roomName.lowercased() {
        case let room where room.contains("kitchen"):
            return "frying.pan.fill"
        case let room where room.contains("bedroom"):
            return "bed.double.fill"
        case let room where room.contains("living"):
            return "sofa.fill"
        case let room where room.contains("bathroom"):
            return "bathtub.fill"
        case let room where room.contains("office"):
            return "laptopcomputer"
        default:
            return "house.fill"
        }
    }
}

#Preview {
    VStack {
        RoomSelectionRow(roomName: "Living Room", isSelected: false) { }
        RoomSelectionRow(roomName: "Kitchen", isSelected: true) { }
        RoomSelectionRow(roomName: "Bedroom", isSelected: false) { }
    }
    .padding()
    .background(Color(.systemGray6))
}
