//
//  RoomCaptureViewWrapper.swift
//  Menata
//
//  Created by Muhamad Azis on 24/06/25.
//

import SwiftUI
import RoomPlan

struct RoomCaptureViewWrapper: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = RoomCaptureViewController()
        vc.dismissHandler = {
            dismiss()
        }

        // Wrap inside UINavigationController to show nav bar
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.tintColor = .white
        navController.navigationBar.barStyle = .black
        navController.navigationBar.prefersLargeTitles = false

        return navController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
