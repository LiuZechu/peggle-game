//
//  Bucket.swift
//  Peggle
//
//  Created by Liu Zechu on 24/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

class Bucket {
    let upperBoundary: Double // location of the rim of the bucket
    let width: Double
    var bottomCenterLocation: CGPoint
    private var speed: Double = 1
    
    func isInBucket(ballLocation: CGPoint, ballRadius: Double) -> Bool {
        let ballLocationX = Double(ballLocation.x)
        let ballLocationY = Double(ballLocation.y)
        let bucketLocationX = Double(bottomCenterLocation.x)

        let isWithinHeight = (ballLocationY - ballRadius) >= upperBoundary
        let isWithinWidth = abs(ballLocationX - bucketLocationX)
            <= (width / 2 - ballRadius)
        
        return isWithinHeight && isWithinWidth
    }
    
    init(upperBoundary: Double, width: Double, bottomCenterLocation: CGPoint) {
        self.upperBoundary = upperBoundary
        self.width = width
        self.bottomCenterLocation = bottomCenterLocation
    }
    
    // Define positive as moving to the right
    func move() {
        bottomCenterLocation.x += CGFloat(speed)
    }
    
    func toggleDirection() {
        speed *= -1
    }
    
    func hitsLeftBoundary(leftBoundary: Double) -> Bool {
        return Double(bottomCenterLocation.x) - width / 2 <= leftBoundary
    }
    
    func hitsRightBoundary(rightBoundary: Double) -> Bool {
        return Double(bottomCenterLocation.x) + width / 2 >= rightBoundary
    }
}
