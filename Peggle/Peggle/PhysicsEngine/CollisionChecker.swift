//
//  CollisionChecker.swift
//  Peggle
//
//  Created by Liu Zechu on 28/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation

class CollisionChecker {
    /// Returns whether the two bodies collide with each other.
    /// `firstBody` must be movable,
    /// `secondBody` can be movable or immovable
    static func isCollision(firstBody: PhysicsBody, secondBody: PhysicsBody) -> Bool {
        // if they are the same body, then not a collision
        guard firstBody != secondBody else {
            return false
        }
        
        if firstBody.shape == .circle && secondBody.shape == .equilateralTriangle {
            return self.isCircleTriangleCollision(firstBody: firstBody, secondBody: secondBody)
        } else { // two circles
            let actualDistance = firstBody.getDistanceFrom(anotherBody: secondBody)
            let collisionDistance = firstBody.radius + secondBody.radius
            
            return actualDistance <= collisionDistance
        }
    }
    
    // Credits: This method is partially adapted from http://www.phatcode.net/articles.php?id=459.

    // TA: Style [-1] SLAP
    private static func isCircleTriangleCollision(firstBody: PhysicsBody, secondBody: PhysicsBody) -> Bool {
        let triangleVertices = secondBody.getVertices()
        let centerX = firstBody.position.xComponent
        let centerY = firstBody.position.yComponent
        let v1x = triangleVertices[0].xComponent
        let v1y = triangleVertices[0].yComponent
        let v2x = triangleVertices[1].xComponent
        let v2y = triangleVertices[1].yComponent
        let v3x = triangleVertices[2].xComponent
        let v3y = triangleVertices[2].yComponent
        let radius = firstBody.radius
        
        //Check whether any vertex is within circle
        var c1x = v1x - centerX
        var c1y = v1y - centerY
        if (c1x * c1x + c1y * c1y).squareRoot() <= radius {
            return true
        }

        var c2x = v2x - centerX
        var c2y = v2y - centerY
        if (c2x * c2x + c2y * c2y).squareRoot() <= radius {
            return true
        }

        var c3x = v3x - centerX
        var c3y = v3y - centerY
        if (c3x * c3x + c3y * c3y).squareRoot() <= radius {
            return true
        }
                    
        // Test whether circle intersects triangle
        // Get the dot product
        c1x = centerX - v1x
        c1y = centerY - v1y
        let e1x = v2x - v1x
        let e1y = v2y - v1y

        var k1 = c1x * e1x + c1y * e1y

        if k1 > 0 {
            let len = (e1x * e1x + e1y * e1y).squareRoot()
            k1 /= len
            
            if k1 < len && (c1x * c1x + c1y * c1y - k1 * k1).squareRoot() <= radius {
                return true
            }
        }

        // Second edge
        c2x = centerX - v2x
        c2y = centerY - v2y
        let e2x = v3x - v2x
        let e2y = v3y - v2y

        var k2 = c2x * e2x + c2y * e2y

        if k2 > 0 {
            let len = (e2x * e2x + e2y * e2y).squareRoot()
            k2 /= len

            if k2 < len && (c2x * c2x + c2y * c2y - k2 * k2).squareRoot() <= radius {
                return true
            }
        }

        // Third edge
        c3x = centerX - v3x
        c3y = centerY - v3y
        let e3x = v1x - v3x
        let e3y = v1y - v3y

        var k3 = c3x * e3x + c3y * e3y

        if k3 > 0 {
            let len = (e3x * e3x + e3y * e3y).squareRoot()
            k3 /= len

            if k3 < len && (c3x * c3x + c3y * c3y - k3 * k3).squareRoot() <= radius {
                return true
            }
        }
        
        return false
    }
}
