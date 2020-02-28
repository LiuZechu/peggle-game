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
            
            //TEST 1: Vertex within circle
            var c1x = v1x - centerX
            var c1y = v1y - centerY
            if (c1x * c1x + c1y * c1y).squareRoot() <= radius {
                print("vertex 1 within circle")
                return true
            }

            var c2x = v2x - centerX
            var c2y = v2y - centerY
            if (c2x * c2x + c2y * c2y).squareRoot() <= radius {
                print("vertex 2 within circle")
                return true
            }

            var c3x = v3x - centerX
            var c3y = v3y - centerY
            if (c3x * c3x + c3y * c3y).squareRoot() <= radius {
                print("vertex 3 within circle")
                return true
            }
            
//            // TEST 2: Circle centre within triangle
//            // NOTE: This works for clockwise ordered vertices!
//            let isWithinFirstSide = ((v2y - v1y) * (centerX - v1x) - (v2x - v1x) * (centerY - v1y)) >= 0
//            let isWithinSecondSide = ((v3y - v2y) * (centerX - v2x) - (v3x - v2x) * (centerY - v2y)) >= 0
//            let isWithinThirdSide = ((v1y - v3y) * (centerX - v3x) - (v1x - v3x) * (centerX - v3x)) >= 0
//            if isWithinFirstSide && isWithinSecondSide && isWithinThirdSide {
//                print("circle center within triangle")
//                return true
//            }
            
            // TEST 3: Circle intersects edge
            // Get the dot product
            c1x = centerX - v1x
            c1y = centerY - v1y
            let e1x = v2x - v1x
            let e1y = v2y - v1y

            var k = c1x * e1x + c1y * e1y

            if k > 0 {
                let len = (e1x * e1x + e1y * e1y).squareRoot()
                k /= len
                
                if k < len && (c1x * c1x + c1y * c1y - k * k).squareRoot() <= radius {
                    print("circle intersects with side 12")
                    return true
                }
            }

            // Second edge
            c2x = centerX - v2x
            c2y = centerY - v2y
            let e2x = v3x - v2x
            let e2y = v3y - v2y

            k = c2x * e2x + c2y * e2y

            if k > 0 {
                let len = (e2x * e2x + e2y * e2y).squareRoot()
                k /= len

                if k < len && (c2x * c2x + c2y * c2y - k * k).squareRoot() <= radius {
                    print("circle intersects with side 23")
                    return true
                }
            }

            // Third edge
            c3x = centerX - v3x
            c3y = centerY - v3y
            let e3x = v1x - v3x
            let e3y = v1y - v3y

            k = c3x * e3x + c3y * e3y

            if k > 0 {
                let len = (e3x * e3x + e3y * e3y).squareRoot()
                k /= len

                if k < len && (c3x * c3x + c3y * c3y - k * k).squareRoot() <= radius {
                    print("circle intersects with side 13")
                    return true
                }
            }
            
            return false
        } else { // two circles
            let actualDistance = firstBody.getDistanceFrom(anotherBody: secondBody)
            let collisionDistance = firstBody.radius + secondBody.radius
            
            return actualDistance <= collisionDistance
        }
    }
}
