//
//  LevelDesignerModelManagerTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class LevelDesignerModelManagerTests: XCTestCase {
    func testInit() {
        let model = LevelDesignerModelManager()
        XCTAssertEqual(model.getCurrentGameBoard().name, "")
    }
    
    func testChangeCurrentGameBoard() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        
        XCTAssertEqual(model.getCurrentGameBoard().name, gameBoard.name)
    }
    
    func testAddPegToCurrentGameBoard_validPeg() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        let peg = Peg(color: .orange, location: CGPoint(x: 12, y: 32), shape: .circle)
        
        let result = model.addPegToCurrentGameBoard(color: .orange, location: CGPoint(x: 12, y: 32), shape: .circle)
        let actualPeg = model.getCurrentGameBoard().pegs.first!
        
        XCTAssertTrue(result)
        XCTAssertEqual(peg, actualPeg)
    }
    
    func testAddPegToCurrentGameBoard_invalidPeg() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        
        let result1 = model.addPegToCurrentGameBoard(color: .orange, location: CGPoint(x: 12, y: 32), shape: .circle)
        let result2 = model.addPegToCurrentGameBoard(color: .orange, location: CGPoint(x: 10, y: 30), shape: .circle)
        
        XCTAssertTrue(result1)
        XCTAssertFalse(result2)
    }
    
    func testRemovePegFromCurrentGameBoard_emptyBoard() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        
        XCTAssertFalse(model.removePegFromCurrentGameBoard(at: CGPoint(x: 12, y: 32)))
       
        let actualCount = model.getCurrentGameBoard().pegs.count
        XCTAssertEqual(actualCount, 0)
    }
    
    func testRemovePegFromCurrentGameBoard_nonemptyBoard() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        _ = model.addPegToCurrentGameBoard(color: .orange, location: CGPoint(x: 12, y: 32), shape: .circle)
        
        XCTAssertTrue(model.removePegFromCurrentGameBoard(at: CGPoint(x: 12, y: 32)))
       
        let actualCount = model.getCurrentGameBoard().pegs.count
        XCTAssertEqual(actualCount, 0)
    }
    
    func testUpdatePegLocation_validUpdate_returnsTrue() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        let initialLocation = CGPoint(x: 12, y: 32)
        let finalLocation = CGPoint(x: 300, y: 300)

        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        _ = model.addPegToCurrentGameBoard(color: .orange, location: initialLocation, shape: .circle)
        
        let result = model.updatePegLocation(from: initialLocation, to: finalLocation, bottomBoundary: 500)
        
        XCTAssertTrue(result)
        
        let actualLocation = model.getCurrentGameBoard().pegs.first!.location
        XCTAssertEqual(actualLocation, finalLocation)
    }
    
    func testUpdatePegLocation_outOfBounds_returnsFalse() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        let initialLocation = CGPoint(x: 12, y: 32)
        let finalLocation = CGPoint(x: 300, y: 1_200)

        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        _ = model.addPegToCurrentGameBoard(color: .orange, location: initialLocation, shape: .circle)
        
        let result = model.updatePegLocation(from: initialLocation, to: finalLocation, bottomBoundary: 1_170)
        
        XCTAssertFalse(result)
        
        let actualLocation = model.getCurrentGameBoard().pegs.first!.location
        XCTAssertEqual(actualLocation, initialLocation)
    }
    
    func testUpdatePegLocation_overlappingPegs_returnsFalse() {
        let gameBoard = GameBoard(name: "board")
        let model = LevelDesignerModelManager()
        let initialLocation = CGPoint(x: 12, y: 32)
        let finalLocation = CGPoint(x: 300, y: 990)
        let overlappingLocation = CGPoint(x: 310, y: 1_000)

        model.changeCurrentGameBoard(newGameBoard: gameBoard)
        _ = model.addPegToCurrentGameBoard(color: .orange, location: initialLocation, shape: .circle)
        
        _ = model.addPegToCurrentGameBoard(color: .orange, location: overlappingLocation, shape: .circle)
        
        let result = model.updatePegLocation(from: initialLocation, to: finalLocation, bottomBoundary: 1_200)
        XCTAssertFalse(result)
    }
    
}
