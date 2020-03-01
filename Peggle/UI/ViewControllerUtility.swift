//
//  ViewControllerUtility.swift
//  Peggle
//
//  Created by Liu Zechu on 29/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerUtility {
    static func getSliderForChangingSize(center: CGPoint, initialValue: Float) -> UISlider {
        let sizeSlider = UISlider()
        sizeSlider.frame = CGRect(x: 0, y: 0, width: 250, height: 35)
        sizeSlider.center = CGPoint(x: center.x, y: center.y - 40)

        sizeSlider.maximumValue = Float(Peg.maximumRadius)
        sizeSlider.minimumValue = Float(Peg.defaultRadius)
        sizeSlider.setValue(initialValue, animated: false)
        sizeSlider.maximumValueImage = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
        
        return sizeSlider
    }
    
    static func getSliderForRotation(center: CGPoint, initialValue: Float) -> UISlider {
        let rotationSlider = UISlider()
        rotationSlider.frame = CGRect(x: 0, y: 0, width: 250, height: 35)
        rotationSlider.center = center

        rotationSlider.maximumValue = 2 * Float.pi
        rotationSlider.minimumValue = 0
        rotationSlider.setValue(initialValue, animated: false)
        rotationSlider.maximumValueImage = UIImage(systemName: "arrow.clockwise")
        
        return rotationSlider
    }
    
    /// Creates a peg's image at corresponding location on the screen, with the specified color.
    static func createPegImageView(at location: CGPoint, color: PegColor, shape: Shape, isGlow: Bool,
                                   radius: CGFloat = Peg.defaultRadius, angle: CGFloat = 0.0) -> UIImageView {
        let frame = CGRect(x: location.x - radius, y: location.y - radius,
                           width: radius * 2, height: radius * 2)
        let imageToAdd = UIImageView(frame: frame)
        if shape == .circle {
            imageToAdd.layer.cornerRadius = frame.height / 2
            imageToAdd.layer.masksToBounds = true
        }
        imageToAdd.contentMode = .scaleAspectFit
        imageToAdd.isUserInteractionEnabled = true
        
        switch color {
        case .blue:
            if shape == .circle {
                imageToAdd.image = isGlow ? UIImage(named: "peg-blue-glow") : UIImage(named: "peg-blue")
            } else {
                imageToAdd.image = isGlow ? UIImage(named: "peg-blue-glow-triangle")
                    : UIImage(named: "peg-blue-triangle")
            }
        case .orange:
            if shape == .circle {
                imageToAdd.image = isGlow ? UIImage(named: "peg-orange-glow") : UIImage(named: "peg-orange")
            } else {
                imageToAdd.image = isGlow ? UIImage(named: "peg-orange-glow-triangle")
                    : UIImage(named: "peg-orange-triangle")
            }
        case .green:
            if shape == .circle {
                imageToAdd.image = isGlow ? UIImage(named: "peg-green-glow") : UIImage(named: "peg-green")
            } else {
                imageToAdd.image = isGlow ? UIImage(named: "peg-green-glow-triangle")
                    : UIImage(named: "peg-green-triangle")
            }
        case .red:
            if shape == .circle {
                imageToAdd.image = isGlow ? UIImage(named: "peg-red-glow") : UIImage(named: "peg-red")
            } else {
                imageToAdd.image = isGlow ? UIImage(named: "peg-red-glow-triangle")
                    : UIImage(named: "peg-red-triangle")
            }
        }
        
        // rotate image
        imageToAdd.transform = CGAffineTransform(rotationAngle: angle)
        
        return imageToAdd
    }
}
