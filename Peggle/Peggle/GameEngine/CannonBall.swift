//
//  CannonBall.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 8/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint

struct CannonBall {
    static let radius = 20.0
    
    var location: CGPoint {
        let xCoord = physicsBody.position.xComponent
        let yCoord = physicsBody.position.yComponent

        return CGPoint(x: xCoord, y: yCoord)
    }
    let physicsBody: PhysicsBody
    
    init(xPosition: Double, yPosition: Double = 100) {
        physicsBody = PhysicsBody(isMovable: true, radius: CannonBall.radius,
                                  initialPosition: Position(xComponent: xPosition, yComponent: yPosition),
                                  initialVelocity: Vector(xComponent: 0, yComponent: 0),
                                  elasticity: 0.95)
    }
    
    func setYLocation(yPosition: Double) {
        physicsBody.position.yComponent = yPosition
    }
}
