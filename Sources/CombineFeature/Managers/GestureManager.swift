//
//  GestureManager.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import UIKit
import ARKit
import RealityKit

class GestureManager {
    
    static func setupGestureRecognizers(_ arView: ARView, coordinator: CanvasCoordinator) {
        // Tap gesture untuk selection
        let tapGesture = UITapGestureRecognizer(target: coordinator, action: #selector(CanvasCoordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Pan gesture untuk rotasi dan translasi
        let panGesture = UIPanGestureRecognizer(target: coordinator, action: #selector(CanvasCoordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        arView.addGestureRecognizer(panGesture)
        
        // Pinch gesture untuk zoom
        let pinchGesture = UIPinchGestureRecognizer(target: coordinator, action: #selector(CanvasCoordinator.handlePinch(_:)))
        arView.addGestureRecognizer(pinchGesture)
        
        // Rotation gesture untuk objek
        let rotationGesture = UIRotationGestureRecognizer(target: coordinator, action: #selector(CanvasCoordinator.handleRotation(_:)))
        arView.addGestureRecognizer(rotationGesture)
        
        // Store reference to ARView
        coordinator.arView = arView
    }
}
