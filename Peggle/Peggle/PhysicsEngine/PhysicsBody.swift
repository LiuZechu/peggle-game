//
//  Circle.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 8/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation

class PhysicsBody: Hashable {
    
    var isMovable: Bool
    var mass: Double
    var velocity: Vector
    var position: Position // center of the circle
    var radius: Double
    var elasticity: Double // 1 means fully elastic i.e. no energy loss upon collision; 0 means fully inelastic.
    var isHit: Bool = false // whether a collision has happened to it
    var angleOfRotation: Double
    var shape: Shape
    
    private var forces: [Vector] // an array of continuous forces; momentary forces are excluded.
    private var resultantForce: Vector {
        var xComponentSum = 0.0
        for force in forces {
            xComponentSum += force.xComponent
        }
        
        var yComponentSum = 0.0
        for force in forces {
            yComponentSum += force.yComponent
        }
        
        return Vector(xComponent: xComponentSum, yComponent: yComponentSum)
    }
    
    init(isMovable: Bool, radius: Double, initialPosition: Position,
         mass: Double = 1, initialVelocity: Vector = Vector(xComponent: 0, yComponent: 0),
         elasticity: Double = 1, shape: Shape = .circle, angleOfRotation: Double = 0) {
        self.isMovable = isMovable
        self.mass = mass
        self.radius = radius
        self.velocity = initialVelocity
        self.position = initialPosition
        self.elasticity = elasticity
        self.forces = []
        self.shape = shape
        self.angleOfRotation = angleOfRotation
        
        // Prevent misassignment of non-zero velocity to an immovable body
        if !isMovable {
            self.velocity = Vector(xComponent: 0, yComponent: 0)
        }
    }

    func applyForce(_ force: Vector) {
        guard isMovable else {
            return
        }
        
        forces.append(force)
    }
    
    func getDistanceFrom(anotherBody: PhysicsBody) -> Double {
        let xDifference = self.position.xComponent - anotherBody.position.xComponent
        let yDifference = self.position.yComponent - anotherBody.position.yComponent
        
        let distanceSquared = pow(xDifference, 2) + pow(yDifference, 2)
        let distance = distanceSquared.squareRoot()
        
        return distance
    }
    
    /// Launches an object at a specified angle, with a specified initial speed (magnitude).
    /// If the body being launched is not movable, do nothing.
    func launch(angle: Double, speed: Double) {
        guard isMovable else {
            return
        }
        
        let weightYComponent = PhysicsEngine.gravity.yComponent * mass
        let weight = Vector(xComponent: 0, yComponent: weightYComponent)
        applyForce(weight)
                
        let xVelocity: Double
        let yVelocity: Double
        
        if angle > 0 {
            xVelocity = speed * cos(angle) + velocity.xComponent
            yVelocity = speed * sin(angle) + velocity.yComponent
        } else {
            xVelocity = speed * -cos(angle) + velocity.xComponent
            yVelocity = speed * -sin(angle) + velocity.yComponent
        }

        velocity = Vector(xComponent: xVelocity, yComponent: yVelocity)
    }
    
    /// Returns an array of vertices of the body, arranged in a clockwise order.
    /// If the body is a circle, it will return an empty set since a circle has no vertices.
    func getVertices() -> [Position] {
        switch self.shape {
        case .circle:
            return []
        case .equilateralTriangle:
            let centerX = position.xComponent
            let centerY = position.yComponent
            let angleOfRotation = self.angleOfRotation.truncatingRemainder(dividingBy: 2 * Double.pi / 3)
            var result = [Position]()
            
            // first vertex
            let addX1 = radius * sin(angleOfRotation)
            let addY1 = -radius * cos(angleOfRotation)
            result.append(Position(xComponent: centerX + addX1, yComponent: centerY + addY1))
            
            // second vertex
            let addX2 = -radius * cos(Double.pi / 6 - angleOfRotation)
            let addY2 = radius * sin(Double.pi / 6 - angleOfRotation)
            result.append(Position(xComponent: centerX + addX2, yComponent: centerY + addY2))

            // third vertex
            let addX3 = radius * cos(Double.pi / 6 + angleOfRotation)
            let addY3 = radius * sin(Double.pi / 6 + angleOfRotation)
            result.append(Position(xComponent: centerX + addX3, yComponent: centerY + addY3))
            
            return result
        }
    }
    
    /// This function calculates and updates the body's position in the next moment in time.
    func update() {
        guard isMovable else {
            return
        }
        
        // update position
        let newPositionX = position.xComponent + velocity.xComponent * (1 / Double(PhysicsEngine.framerate))
        let newPositionY = position.yComponent + velocity.yComponent * (1 / Double(PhysicsEngine.framerate))
        position = Position(xComponent: newPositionX, yComponent: newPositionY)
                
        // update velocity
        let accelerationX = resultantForce.xComponent / mass
        let accelerationY = resultantForce.yComponent / mass
        let newVelocityX = velocity.xComponent + accelerationX * (1 / Double(PhysicsEngine.framerate))
        let newVelocityY = velocity.yComponent + accelerationY * (1 / Double(PhysicsEngine.framerate))
        velocity = Vector(xComponent: newVelocityX, yComponent: newVelocityY)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }
    
    static func == (lhs: PhysicsBody, rhs: PhysicsBody) -> Bool {
        return lhs.position == rhs.position
    }
}
