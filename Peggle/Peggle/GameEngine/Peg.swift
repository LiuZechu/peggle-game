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
    static let defaultRadius: CGFloat = 20
    static let maximumRadius: CGFloat = 40
    
    var powerup: Powerup?
    
    var color: PegColor
    var shape: Shape {
        get {
            return physicsBody.shape
        }
        
        set {
            physicsBody.shape = newValue
        }
    }
    var radius: CGFloat {
        get {
            return CGFloat(physicsBody.radius)
        }
        
        set {
            physicsBody.radius = Double(newValue)
        }
    }
    var angleOfRotation: CGFloat {
        get {
            return CGFloat(physicsBody.angleOfRotation)
        }
        
        set {
            physicsBody.angleOfRotation = Double(newValue)
        }
    }
    
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
    var isHit: Bool {
        get {
            return physicsBody.isHit
        }
        
        set {
            physicsBody.isHit = newValue
        }
    }
    // this attribute shows whether the peg's hit status has been noticed
    var hasBeenHit = false
    
    private var hasPowerupBeenActivated = false
        
    init(color: PegColor, location: CGPoint, shape: Shape, powerup: Powerup? = nil,
         radius: CGFloat = Peg.defaultRadius, angleOfRotation: CGFloat = 0.0) {
        self.color = color
        self.physicsBody = PhysicsBody(isMovable: false, radius: Double(radius),
                                       initialPosition: location.toPosition(),
                                       shape: shape, angleOfRotation: Double(angleOfRotation))
        self.shape = shape
        self.radius = radius
        self.powerup = powerup
        self.angleOfRotation = angleOfRotation
    }
    
    func isOverlapping(with peg: Peg) -> Bool {
        let distance = getDistanceFrom(otherPeg: peg)
        return distance < Double(self.radius + peg.radius)
    }
    
    func getDistanceFrom(otherPeg: Peg) -> Double {
        let thisLocation = location
        let otherLocation = otherPeg.location
        
        let xDiff = Double(abs(thisLocation.x - otherLocation.x))
        let yDiff = Double(abs(thisLocation.y - otherLocation.y))
        
        let xDiffSquared = pow(xDiff, 2.0)
        let yDiffSquared = pow(yDiff, 2.0)
        let distance = (xDiffSquared + yDiffSquared).squareRoot()
        
        return distance
    }
    
    func isPowerupActivated() -> Bool {
        let result = color == .green && isHit == true && hasPowerupBeenActivated == false
        if result {
            hasPowerupBeenActivated = true
        }
        return result
    }
    
    func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    static func == (lhs: Peg, rhs: Peg) -> Bool {
        return lhs.location == rhs.location
    }
}
