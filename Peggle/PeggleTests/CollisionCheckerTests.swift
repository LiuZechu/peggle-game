//
//  CollisionCheckerTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class CollisionCheckerTests: XCTestCase {
      func testIsCollision_close_returnsTrue() {
          let body1 = PhysicsBody(isMovable: true, radius: 20,
                                  initialPosition: Position(xComponent: 50, yComponent: 60))
          let body2 = PhysicsBody(isMovable: true, radius: 50,
                                  initialPosition: Position(xComponent: 65, yComponent: 70))
          
          XCTAssertTrue(CollisionChecker.isCollision(firstBody: body1, secondBody: body2))
      }
      
      func testIsCollision_far_returnsFalse() {
          let body1 = PhysicsBody(isMovable: true, radius: 20,
                                  initialPosition: Position(xComponent: 500, yComponent: 600))
          let body2 = PhysicsBody(isMovable: true, radius: 50,
                                  initialPosition: Position(xComponent: 65, yComponent: 70))
          
          XCTAssertFalse(CollisionChecker.isCollision(firstBody: body1, secondBody: body2))
      }
      
      func testIsCollision_sameBody_returnsFalse() {
          let body1 = PhysicsBody(isMovable: true, radius: 20,
                                  initialPosition: Position(xComponent: 50, yComponent: 60))
    
          XCTAssertFalse(CollisionChecker.isCollision(firstBody: body1, secondBody: body1))
      }
}
