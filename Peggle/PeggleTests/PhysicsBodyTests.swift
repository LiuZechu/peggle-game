//
//  PhysicsBodyTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class PhysicsBodyTests: XCTestCase {

    func testApplyForceAndUpdate_movable() {
        let body = PhysicsBody(isMovable: true, radius: 20,
                               initialPosition: Position(xComponent: 0, yComponent: 0),
                               mass: 20)
        
        body.applyForce(Vector(xComponent: 50, yComponent: 0))
        
        for _ in 1...(PhysicsEngine.framerate * 3) { // move for 3 seconds
            body.update()
        }
        
        let acceleration = 50.0 / 20.0
        let expectedX = 0.5 * acceleration * (3 * 3)
        let actualX = body.position.xComponent
        let expectedY = 0.0
        let actualY = body.position.yComponent
        
        XCTAssertEqual(expectedX, actualX, accuracy: 1)
        XCTAssertEqual(expectedY, actualY, accuracy: 1)
    }
    
    func testApplyForceAndUpdate_immovable() {
        let body = PhysicsBody(isMovable: false, radius: 20,
                               initialPosition: Position(xComponent: 0, yComponent: 0),
                               mass: 20)
        
        body.applyForce(Vector(xComponent: 50, yComponent: 0))
        
        for _ in 1...(PhysicsEngine.framerate * 3) { // move for 3 seconds
            body.update()
        }
        
        let expectedX = 0.0
        let actualX = body.position.xComponent
        let expectedY = 0.0
        let actualY = body.position.yComponent
        
        XCTAssertEqual(expectedX, actualX)
        XCTAssertEqual(expectedY, actualY)
    }

    func testLaunch_movable() {
        let body = PhysicsBody(isMovable: true, radius: 20,
                               initialPosition: Position(xComponent: 0, yComponent: 0),
                               mass: 20)
        body.launch(angle: 0.000_000_000_001, speed: 100)
        
        for _ in 1...(PhysicsEngine.framerate * 3) { // move for 3 seconds
            body.update()
        }
        
        let expectedX = 3.0 * 100.0
        let actualX = body.position.xComponent
        let expectedY = 0.5 * PhysicsEngine.gravity.yComponent * (3 * 3)
        let actualY = body.position.yComponent
        
        XCTAssertEqual(expectedX, actualX, accuracy: 1)
        XCTAssertEqual(expectedY, actualY, accuracy: 5)
    }
    
    func testLaunch_immovable() {
        let body = PhysicsBody(isMovable: false, radius: 20,
                               initialPosition: Position(xComponent: 0, yComponent: 0),
                               mass: 20)
        body.launch(angle: 0, speed: 100)
        
        for _ in 1...(PhysicsEngine.framerate * 3) { // move for 3 seconds
            body.update()
        }
        
        let expectedX = 0.0
        let actualX = body.position.xComponent
        let expectedY = 0.0
        let actualY = body.position.yComponent
        
        XCTAssertEqual(expectedX, actualX)
        XCTAssertEqual(expectedY, actualY)
    }
    
    func testGetDistanceFrom_differentBodies() {
        let body1 = PhysicsBody(isMovable: false, radius: 20,
                                initialPosition: Position(xComponent: 0, yComponent: 0),
                                mass: 20)
        let body2 = PhysicsBody(isMovable: false, radius: 20,
                                initialPosition: Position(xComponent: 100, yComponent: 28),
                                mass: 20)
        let expected = (100.0 * 100.0 + 30.0 * 30.0).squareRoot()
        
        XCTAssertEqual(expected, body1.getDistanceFrom(anotherBody: body2), accuracy: 1)
    }
    
    func testGetDistanceFrom_sameBody() {
        let body = PhysicsBody(isMovable: false, radius: 20,
                               initialPosition: Position(xComponent: 0, yComponent: 0),
                               mass: 20)
        let expected = 0.0
        
        XCTAssertEqual(expected, body.getDistanceFrom(anotherBody: body))
    }

}
