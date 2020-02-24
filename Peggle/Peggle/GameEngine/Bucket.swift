//
//  Bucket.swift
//  Peggle
//
//  Created by Liu Zechu on 24/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint

struct Bucket {
    let upperBoundary: Double // location of the rim of the bucket
    let width: Double
    let bottomCenterLocation: CGPoint
    
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
    
}
