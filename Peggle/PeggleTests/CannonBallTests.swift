//
//  CannonBallTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class CannonBallTests: XCTestCase {
    func testInit() {
        let ball = CannonBall(xPosition: 500)
        
        let expectedX = 500.0
        let actualX = ball.location.toPosition().xComponent
        let expectedY = 100.0
        let actualY = ball.location.toPosition().yComponent
        
        XCTAssertEqual(expectedX, actualX)
        XCTAssertEqual(expectedY, actualY)
    }
}
