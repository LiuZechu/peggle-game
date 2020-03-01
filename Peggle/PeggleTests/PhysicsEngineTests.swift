//
//  PhysicsEngineTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class PhysicsEngineTests: XCTestCase {
    
    func testInit() {
        let physicsEngine = PhysicsEngine(leftBoundary: 5,
                                          rightBoundary: 700,
                                          upperBoundary: 50,
                                          lowerBoundary: 800)
        XCTAssertEqual(physicsEngine.leftBoundary, 5)
        XCTAssertEqual(physicsEngine.rightBoundary, 700)
        XCTAssertEqual(physicsEngine.upperBoundary, 50)
        XCTAssertEqual(physicsEngine.lowerBoundary, 800)
    }
    
    func testAddPhysicsBody_success() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body1 = PhysicsBody(isMovable: true, radius: 20,
                                initialPosition: Position(xComponent: 50, yComponent: 60))
        let body2 = PhysicsBody(isMovable: true, radius: 20,
                                initialPosition: Position(xComponent: 100, yComponent: 60))
        
        let result1 = physicsEngine.addPhysicsBody(body1)
        let result2 = physicsEngine.addPhysicsBody(body2)
        
        XCTAssertTrue(result1)
        XCTAssertTrue(result2)
        XCTAssertTrue(physicsEngine.contains(body: body1))
        XCTAssertTrue(physicsEngine.contains(body: body2))
    }
    
    func testAddPhysicsBody_overlapping_failure() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body1 = PhysicsBody(isMovable: true, radius: 20,
                                initialPosition: Position(xComponent: 50, yComponent: 60))
        let body2 = PhysicsBody(isMovable: true, radius: 20,
                                initialPosition: Position(xComponent: 45, yComponent: 60))
        
        let result1 = physicsEngine.addPhysicsBody(body1)
        let result2 = physicsEngine.addPhysicsBody(body2)
        
        XCTAssertTrue(result1)
        XCTAssertFalse(result2)
        XCTAssertTrue(physicsEngine.contains(body: body1))
        XCTAssertFalse(physicsEngine.contains(body: body2))
    }
    
    func testRemovePhysicsBody_success() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body = PhysicsBody(isMovable: true, radius: 20,
                               initialPosition: Position(xComponent: 50, yComponent: 60))
        
        _ = physicsEngine.addPhysicsBody(body)
        XCTAssertTrue(physicsEngine.contains(body: body))

        let result = physicsEngine.removePhysicsBody(body)
        XCTAssertTrue(result)
        XCTAssertFalse(physicsEngine.contains(body: body))
    }
    
    func testRemovePhysicsBody_nonexistent_failure() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body1 = PhysicsBody(isMovable: true, radius: 20,
                                initialPosition: Position(xComponent: 50, yComponent: 60))
        let body2 = PhysicsBody(isMovable: true, radius: 20,
                                initialPosition: Position(xComponent: 10, yComponent: 600))
        
        _ = physicsEngine.addPhysicsBody(body1)
        XCTAssertTrue(physicsEngine.contains(body: body1))
        
        let result1 = physicsEngine.removePhysicsBody(body1)
        let result2 = physicsEngine.removePhysicsBody(body2)

        XCTAssertTrue(result1)
        XCTAssertFalse(result2)
        XCTAssertFalse(physicsEngine.contains(body: body1))
        XCTAssertFalse(physicsEngine.contains(body: body2))
    }
        
    func testBodyOutOfLowerBound_returnsTrue() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body = PhysicsBody(isMovable: true, radius: 20,
                               initialPosition: Position(xComponent: 50, yComponent: 2_021))
        
        XCTAssertTrue(physicsEngine.isBodyOutOfLowerBound(body: body))
    }
    
    func testBodyOutOfLowerBound_returnsFalse() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body = PhysicsBody(isMovable: true, radius: 20,
                               initialPosition: Position(xComponent: 50, yComponent: 1_000))
        
        XCTAssertFalse(physicsEngine.isBodyOutOfLowerBound(body: body))
    }
    
    func testFreeFall_for3Seconds() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body = PhysicsBody(isMovable: true, radius: 20,
                               initialPosition: Position(xComponent: 0, yComponent: 0))
        _ = physicsEngine.addPhysicsBody(body)
        body.launch(angle: Double.pi / 2, speed: 0)
        
        for _ in 1...(PhysicsEngine.framerate * 3) { // 3 seconds of free fall
            physicsEngine.update()
        }
        
        let expectedXPosition = 0.0
        let expectedYPosition = 0.5 * PhysicsEngine.gravity.yComponent * (3 * 3)
        let actualXPosition = body.position.xComponent
        let actualYPosition = body.position.yComponent

        XCTAssertEqual(expectedXPosition, actualXPosition, accuracy: 0.5)
        XCTAssertEqual(expectedYPosition, actualYPosition, accuracy: 10) // greater error at high speeds
    }
    
    func testFall_for2SecondsWithInitialSpeedAtAnAngle() {
        let physicsEngine = PhysicsEngine(leftBoundary: 0,
                                          rightBoundary: 1_000,
                                          upperBoundary: 0,
                                          lowerBoundary: 2_000)
        let body = PhysicsBody(isMovable: true, radius: 20,
                               initialPosition: Position(xComponent: 0, yComponent: 0))
        _ = physicsEngine.addPhysicsBody(body)
        body.launch(angle: Double.pi / 4, speed: 100)
        
        for _ in 1...(PhysicsEngine.framerate * 2) { // 2 seconds of fall
            physicsEngine.update()
        }
        
        let velocityComponentValue = 100 / (2.0.squareRoot())
        
        let expectedXPosition = velocityComponentValue * 2
        let expectedYPosition = velocityComponentValue * 2 + 0.5 * PhysicsEngine.gravity.yComponent * (2 * 2)
        let actualXPosition = body.position.xComponent
        let actualYPosition = body.position.yComponent

        XCTAssertEqual(expectedXPosition, actualXPosition, accuracy: 0.5)
        XCTAssertEqual(expectedYPosition, actualYPosition, accuracy: 5) // greater error at high speeds
    }

}
