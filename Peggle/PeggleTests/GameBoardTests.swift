//
//  GameBoardTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class GameBoardTests: XCTestCase {
    func testInitOneArgument() {
        let gameBoard = GameBoard(name: "first")
        XCTAssertEqual(gameBoard.name, "first")
    }
    
    func testInitTwoArguments() {
        let pegSet = Set<Peg>([Peg(color: .blue, location: CGPoint.zero, shape: .circle)])
        let gameBoard = GameBoard(name: "second", pegs: pegSet)
        
        XCTAssertEqual(gameBoard.name, "second")
        XCTAssertEqual(gameBoard.pegs, pegSet)
    }
    
    func testAddPeg_validPeg_addSucceeds() {
        let gameBoard = GameBoard(name: "board")
        let firstPeg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        let result = gameBoard.addPeg(toAdd: firstPeg)
        
        XCTAssertTrue(result)
        XCTAssertEqual(gameBoard.pegs, Set<Peg>([firstPeg]))
    }
    
    func testAddPeg_overlappingPeg_addFails() {
        let gameBoard = GameBoard(name: "board")
        let firstPeg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        let overlappingPeg = Peg(color: .orange, location: CGPoint(x: 6, y: 6), shape: .circle)
        _ = gameBoard.addPeg(toAdd: firstPeg)
        let result = gameBoard.addPeg(toAdd: overlappingPeg)
        
        XCTAssertFalse(result)
        XCTAssertEqual(gameBoard.pegs, Set<Peg>([firstPeg]))
    }
    
    func testRemovePeg_existingPeg_removeSucceeds() {
        let gameBoard = GameBoard(name: "board")
        let firstPeg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        _ = gameBoard.addPeg(toAdd: firstPeg)
        let result = gameBoard.removePeg(toRemove: firstPeg)
        
        XCTAssertTrue(result)
        XCTAssertEqual(gameBoard.pegs, Set<Peg>())
    }
    
    func testRemovePeg_nonexistentPeg_removeFails() {
        let gameBoard = GameBoard(name: "board")
        let firstPeg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        let anotherPeg = Peg(color: .orange, location: CGPoint(x: 30, y: 60), shape: .circle)
        _ = gameBoard.addPeg(toAdd: firstPeg)
        let result = gameBoard.removePeg(toRemove: anotherPeg)
        
        XCTAssertFalse(result)
        XCTAssertEqual(gameBoard.pegs, Set<Peg>([firstPeg]))
    }
    
    func testRemovePeg_nonexistentPegInEmptyGameBoard_removeFails() {
        let gameBoard = GameBoard(name: "board")
        let peg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        let result = gameBoard.removePeg(toRemove: peg)
        
        XCTAssertFalse(result)
        XCTAssertEqual(gameBoard.pegs, Set<Peg>())
    }
    
    func testPegDoesOverlap_overlappingPegs() {
        let gameBoard = GameBoard(name: "board")
        let firstPeg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        let anotherPeg = Peg(color: .orange, location: CGPoint(x: 5, y: 5), shape: .circle)
        _ = gameBoard.addPeg(toAdd: firstPeg)
        
        XCTAssertTrue(gameBoard.pegDoesOverlap(peg: anotherPeg))
    }
    
    func testPegDoesOverlap_noOverlappingPegs() {
        let gameBoard = GameBoard(name: "board")
        let firstPeg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        let anotherPeg = Peg(color: .orange, location: CGPoint(x: 50, y: 50), shape: .circle)
        _ = gameBoard.addPeg(toAdd: firstPeg)
        
        XCTAssertFalse(gameBoard.pegDoesOverlap(peg: anotherPeg))
    }
    
    func testClearAllPegs_emptyGameBoard() {
        let gameBoard = GameBoard(name: "board")
        gameBoard.clearAllPegs()
        
        XCTAssertEqual(gameBoard.pegs, Set<Peg>())
    }
    
    func testClearAllPegs_nonEmptyGameBoard() {
        let gameBoard = GameBoard(name: "board")
        let firstPeg = Peg(color: .orange, location: CGPoint(x: 3, y: 3), shape: .circle)
        _ = gameBoard.addPeg(toAdd: firstPeg)
        gameBoard.clearAllPegs()
        
        XCTAssertEqual(gameBoard.pegs, Set<Peg>())
    }

}
