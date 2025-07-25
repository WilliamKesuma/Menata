//
//  ContentView.swift
//  Sandbox
//
//  Created by 日野森寛也 on 2024/04/08.
//  Edited by Muhamad Azis pm 2025/06/24
//

import SwiftUI
import Capture
import Common

@MainActor
public struct ContentView: View {
    let captureModel: CapturingModel = .instance

    public init() { }

    public var body: some View {
        VStack {
            Text("Use ScannerView instead")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}

