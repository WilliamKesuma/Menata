//
//  TextureGenerator.swift
//  Canvas3DDragDrop
//
//  Created by Muhamad Azis on 23/06/25.
//

import Foundation
import UIKit
import CoreGraphics

class TextureGenerator {
    
    static func createGrayGridTexture() -> CGImage {
        let size = CGSize(width: 512, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let cgContext = context.cgContext
            
            // Gray background
            cgContext.setFillColor(UIColor.systemGray6.cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))
            
            // Dark gray grid lines
            cgContext.setStrokeColor(UIColor.systemGray3.cgColor)
            cgContext.setLineWidth(2.0)
            
            let gridSize: CGFloat = 32
            
            // Vertical lines
            for i in stride(from: 0, through: size.width, by: gridSize) {
                cgContext.move(to: CGPoint(x: i, y: 0))
                cgContext.addLine(to: CGPoint(x: i, y: size.height))
            }
            
            // Horizontal lines
            for i in stride(from: 0, through: size.height, by: gridSize) {
                cgContext.move(to: CGPoint(x: 0, y: i))
                cgContext.addLine(to: CGPoint(x: size.width, y: i))
            }
            
            cgContext.strokePath()
        }
        
        return image.cgImage!
    }
}
