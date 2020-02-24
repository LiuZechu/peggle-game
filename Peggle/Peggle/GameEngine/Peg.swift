//
//  Peg.swift
//  Peggle
//
//  Created by Liu Zechu on 25/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

class Peg: Hashable {
    static let radius: CGFloat = 20
    
    let color: PegColor
    var location: CGPoint {
        get {
            let xComponent = physicsBody.position.xComponent
            let yComponent = physicsBody.position.yComponent
            return CGPoint(x: xComponent, y: yComponent)
        }
        
        set {
            let xComponent = Double(newValue.x)
            let yComponent = Double(newValue.y)
            let newPosition = Position(xComponent: xComponent, yComponent: yComponent)
            physicsBody.position = newPosition
        }
    }
    
    let physicsBody: PhysicsBody
    var isHit = false
    
    init(color: PegColor, location: CGPoint) {
        self.color = color
        self.physicsBody = PhysicsBody(isMovable: false, radius: Double(Peg.radius),
                                       initialPosition: location.toPosition())
    }
    
    func isOverlapping(with peg: Peg) -> Bool {
        let thisLocation = location
        let otherLocation = peg.location
        
        let xDiff = Double(abs(thisLocation.x - otherLocation.x))
        let yDiff = Double(abs(thisLocation.y - otherLocation.y))
        
        let xDiffSquared = pow(xDiff, 2.0)
        let yDiffSquared = pow(yDiff, 2.0)
        let distance = (xDiffSquared + yDiffSquared).squareRoot()
        
        return distance < Double(Peg.radius * 2)
    }
    
    func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    static func == (lhs: Peg, rhs: Peg) -> Bool {
        return lhs.location == rhs.location
    }
}
