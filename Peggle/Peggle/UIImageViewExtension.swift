//
//  UIImageViewExtension.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 9/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    /// Determines whether this circular image view contains the specified location on the screen.
    func containsLocation(location: CGPoint, circleRadius: CGFloat) -> Bool {
        let xDifference = Double(self.center.x) - Double(location.x)
        let yDifference = Double(self.center.y) - Double(location.y)

        let xDifferenceSquared = pow(xDifference, 2)
        let yDifferenceSquared = pow(yDifference, 2)
        
        let distance = (xDifferenceSquared + yDifferenceSquared).squareRoot()

        return distance < Double(circleRadius)
    }
}
