//
//  PegTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class PegTests: XCTestCase {

    func testInit() {
        let peg = Peg(color: .blue, location: CGPoint(x: 1.2, y: 3.4), shape: .circle)
        
        XCTAssertEqual(peg.color, PegColor.blue)
        XCTAssertEqual(peg.location, CGPoint(x: 1.2, y: 3.4))
    }
    
    func testIsOverLapping_notOverLapping_returnsFalse() {
        let peg1 = Peg(color: .blue, location: CGPoint(x: 30, y: 30), shape: .circle)
        let peg2 = Peg(color: .blue, location: CGPoint(x: 100, y: 100), shape: .circle)
        
        XCTAssertFalse(peg1.isOverlapping(with: peg2))
        XCTAssertFalse(peg2.isOverlapping(with: peg1))
    }

    func testIsOverLapping_overLapping_returnsTrue() {
        let peg1 = Peg(color: .blue, location: CGPoint(x: 30, y: 30), shape: .circle)
        let peg2 = Peg(color: .blue, location: CGPoint(x: 40, y: 30), shape: .circle)
        
        XCTAssertTrue(peg1.isOverlapping(with: peg2))
        XCTAssertTrue(peg2.isOverlapping(with: peg1))
    }
    
    func testEqual_sameLocation_returnsTrue() {
        let peg1 = Peg(color: .blue, location: CGPoint(x: 30, y: 30), shape: .circle)
        let peg2 = Peg(color: .blue, location: CGPoint(x: 30, y: 30), shape: .circle)
        
        XCTAssertTrue(peg1 == peg2)
    }
    
    func testEqual_differentLocation_returnsFalse() {
        let peg1 = Peg(color: .blue, location: CGPoint(x: 30, y: 30), shape: .circle)
        let peg2 = Peg(color: .blue, location: CGPoint(x: 40, y: 40), shape: .circle)
        
        XCTAssertFalse(peg1 == peg2)
    }
}
