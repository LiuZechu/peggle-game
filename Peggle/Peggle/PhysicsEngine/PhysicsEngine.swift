//
//  PhysicsEngine.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 8/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation

class PhysicsEngine {
    static let gravity = Vector(xComponent: 0, yComponent: 200) // define downwards as positive
    static let framerate = 60
    
    // boundaries
    var leftBoundary: Double
    var rightBoundary: Double
    var upperBoundary: Double
    var lowerBoundary: Double
    
    private var movableBodies: Set<PhysicsBody>
    private var immovableBodies: Set<PhysicsBody>
    
    init(leftBoundary: Double, rightBoundary: Double, upperBoundary: Double, lowerBoundary: Double) {
        movableBodies = []
        immovableBodies = []
        
        self.leftBoundary = leftBoundary
        self.rightBoundary = rightBoundary
        self.upperBoundary = upperBoundary
        self.lowerBoundary = lowerBoundary
    }
    
    /// Returns a boolean value to indicate whether the body is successfully added.
    /// If the body overlaps with another body, false will be returned.
    func addPhysicsBody(_ body: PhysicsBody) -> Bool {
        // check for overlaps
        for anotherBody in movableBodies.union(immovableBodies) {
            if isCollision(firstBody: body, secondBody: anotherBody) {
                return false
            }
        }
        
        // currently, this physics engine only supports movable/immovable circles and immovable triangles
        if body.shape == .equilateralTriangle && body.isMovable {
            return false
        }
        
        if body.isMovable {
            movableBodies.insert(body)
        } else {
            immovableBodies.insert(body)
        }
        
        return true
    }
    
    /// Returns a boolean value to indicate whether the body is successfully removed.
    /// If the body doesn't exist, false will be returned.
    func removePhysicsBody(_ body: PhysicsBody) -> Bool {
        if body.isMovable {
            return movableBodies.remove(body) != nil
        } else {
            return immovableBodies.remove(body) != nil
        }
    }
    
    /// Returns true if the specified physics body exists in this physics engine.
    func contains(body: PhysicsBody) -> Bool {
        return movableBodies.contains(body) || immovableBodies.contains(body)
    }
    
    /// Returns whether the two bodies collide with each other.
    /// `firstBody` must be movable,
    /// `secondBody` can be movable or immovable
    func isCollision(firstBody: PhysicsBody, secondBody: PhysicsBody) -> Bool {
        // if they are the same body, then not a collision
        guard firstBody != secondBody else {
            return false
        }
        
        if firstBody.shape == .circle && secondBody.shape == .equilateralTriangle {
            // SOMETHING
            return false
        } else { // two circles
            let actualDistance = firstBody.getDistanceFrom(anotherBody: secondBody)
            let collisionDistance = firstBody.radius + secondBody.radius
            
            return actualDistance <= collisionDistance
        }
    }
    
    func update() {
        for body in movableBodies {
            body.update()
            
            // detect collisions with other bodies
            for otherBody in movableBodies.union(immovableBodies) {
                if isCollision(firstBody: body, secondBody: otherBody) {
                    body.isHit = true
                    otherBody.isHit = true
                    resolveCollision(firstBody: body, secondBody: otherBody)
                }
            }
            
            // detect reflections from walls/boundaries
            let exceedsLeft = body.position.xComponent <= (leftBoundary + body.radius)
            let exceedsRight = body.position.xComponent >= (rightBoundary - body.radius)
            let exceedsUpper = body.position.yComponent <= (upperBoundary + body.radius)
            if exceedsLeft || exceedsRight {
                resolveHorizontalReflectionFromWall(movableBody: body)
            } else if exceedsUpper {
                resolveVerticalReflectionFromWall(movableBody: body)
            }

//            // anything out of the lower bound will be removed
//            if bodyOutOfLowerBound(body: body) {
//                movableBodies.remove(body)
//            }
        }
    }
    
    /// Determines whether the specified body exceeds the lower boundary of this physics space.
    func isBodyOutOfLowerBound(body: PhysicsBody) -> Bool {
        return (body.position.yComponent - body.radius) > lowerBoundary
    }
    
    private func resolveHorizontalReflectionFromWall(movableBody: PhysicsBody) {
        // prevent the ball from getting stuck at the wall
        let isOverlapping = movableBody.velocity.xComponent
            * (movableBody.position.xComponent - movableBody.radius) <= 0
        guard !isOverlapping else {
            return
        }
        
        movableBody.velocity.xComponent *= -1 * movableBody.elasticity
    }
    
    private func resolveVerticalReflectionFromWall(movableBody: PhysicsBody) {
        // prevent the ball from getting stuck at the wall
        let isOverlapping = movableBody.velocity.yComponent
            * (movableBody.position.yComponent - movableBody.radius) <= 0
        guard !isOverlapping else {
            return
        }
        
        movableBody.velocity.yComponent *= -1 * movableBody.elasticity
    }
    
    // Credits: the following collision equations are adapted from this website:
    // https://gist.github.com/christopher4lis/f9ccb589ee8ecf751481f05a8e59b1dc
    /// Updates the velocities of the two bodies undergoing collision.
    /// - Parameters
    ///   - firstBody: a movable colliding physics body.
    ///   - secondBody: either a movable colliding physics body, or an immovable one against which `firstBody` collides.
    private func resolveCollision(firstBody: PhysicsBody, secondBody: PhysicsBody) {
        let xVelocityDiff = firstBody.velocity.xComponent - secondBody.velocity.xComponent
        let yVelocityDiff = firstBody.velocity.yComponent - secondBody.velocity.yComponent

        let xDistanceDiff = secondBody.position.xComponent - firstBody.position.xComponent
        let yDistanceDiff = secondBody.position.yComponent - firstBody.position.yComponent

        // prevent accidental overlap of circles
        let isOverlapping = xVelocityDiff * xDistanceDiff + yVelocityDiff * yDistanceDiff <= 0
        
        guard !isOverlapping else {
            return
        }
   
        // angle between the two colliding particles
        let angle = -atan2(yDistanceDiff, xDistanceDiff)
        
        let m1 = firstBody.mass
        let m2 = secondBody.mass
        
        // velocities before collision, transformed into linear velocities along a 1D horizontal line
        let u1 = rotate(velocity: firstBody.velocity, angle: angle)
        let u2 = rotate(velocity: secondBody.velocity, angle: angle)
        
        // velocities after 1D collision
        let v1X: Double
        let v1Y: Double
        let v2X: Double
        let v2Y: Double
        
        if secondBody.isMovable {
            v1X = u1.xComponent * ((m1 - m2) / (m1 + m2)) + u2.xComponent * 2 * (m2 / (m1 + m2))
            v1Y = u1.yComponent
            v2X = u2.xComponent * ((m2 - m1) / (m1 + m2)) + u1.xComponent * 2 * (m1 / (m1 + m2))
            v2Y = u2.yComponent
        } else {
            v1X = -u1.xComponent
            v1Y = u1.yComponent
            v2X = u2.xComponent
            v2Y = u2.yComponent
        }
        
        // multiplied by elasticity to account for energy loss
        let v1 = Vector(xComponent: v1X * firstBody.elasticity, yComponent: v1Y * firstBody.elasticity)
        let v2 = Vector(xComponent: v2X * secondBody.elasticity, yComponent: v2Y * secondBody.elasticity)

        // final velocities after rotating axis back to original location
        let vFinal1 = rotate(velocity: v1, angle: -angle)
        let vFinal2 = rotate(velocity: v2, angle: -angle)
        
        firstBody.velocity.xComponent = vFinal1.xComponent
        firstBody.velocity.yComponent = vFinal1.yComponent
        secondBody.velocity.xComponent = vFinal2.xComponent
        secondBody.velocity.yComponent = vFinal2.yComponent
    }
    
    /// Transforms a vector into a horizontal vector along a 1D line,
    /// in order to simplify a collision in the 2D plane into a linear collision.
    private func rotate(velocity: Vector, angle: Double) -> Vector {
        let newVelocityX = velocity.xComponent * cos(angle) - velocity.yComponent * sin(angle)
        let newVelocityY = velocity.xComponent * sin(angle) + velocity.yComponent * cos(angle)
        let rotatedVelocity = Vector(xComponent: newVelocityX, yComponent: newVelocityY)
        
        return rotatedVelocity
    }

}
