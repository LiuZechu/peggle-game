//
//  StorageManagerTests.swift
//  PeggleTests
//
//  Created by Liu Zechu on 1/3/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import XCTest
@testable import Peggle

class StorageManagerTests: XCTestCase {
    func testSaveOldGameBoard_saveSuccessful() {
        let storage = StorageManager()
        let model = ModelStub(testCase: 1)
        let result = storage.saveOldGameBoard(model: model)
        
        XCTAssertTrue(result)
    }
    
    func testSaveNewGameBoard_nameAlreadyExists_saveUnsuccessful() {
        let storage = StorageManager()
        let model = ModelStub(testCase: 1)
        let anotherModel = ModelStub(testCase: 2)
        _ = storage.saveOldGameBoard(model: model)
        let result = storage.saveNewGameBoard(model: anotherModel)
        
        XCTAssertFalse(result)
    }
    
    func testSaveNewGameBoard_emptyName_saveUnsuccessful() {
        let storage = StorageManager()
        let model = ModelStub(testCase: 3)
        let result = storage.saveNewGameBoard(model: model)
        
        XCTAssertFalse(result)
    }
    
    func testFetchGameBoardByName_validName_success() {
        let storage = StorageManager()
        let model = ModelStub(testCase: 4)
        _ = storage.saveNewGameBoard(model: model)
        
        let name = model.getCurrentGameBoard().name
        let actualGameBoard = storage.fetchGameBoardByName(name: name)
        let expectedGameBoard = model.getCurrentGameBoard()
        
        XCTAssertEqual(actualGameBoard?.name, expectedGameBoard.name)
    }
    
    func testFetchGameBoardByName_nonexistentName_fails() {
        let storage = StorageManager()
        let model = ModelStub(testCase: 4)
        _ = storage.saveNewGameBoard(model: model)
        
        let actualGameBoard = storage.fetchGameBoardByName(name: "nonexistent")
        
        XCTAssertNil(actualGameBoard)
    }
    
    func testFetchGameBoardByName_emptyName_fails() {
        let storage = StorageManager()
        let model = ModelStub(testCase: 4)
        _ = storage.saveNewGameBoard(model: model)
        
        let actualGameBoard = storage.fetchGameBoardByName(name: "  ")
        
        XCTAssertNil(actualGameBoard)
    }
    
}

private class ModelStub: LevelDesignerModel {

    var currentGameBoard: GameBoard
    
    init(testCase: Int) {
        switch testCase {
        case 1:
            let peg1 = Peg(color: .blue, location: CGPoint(x: 55, y: 66), shape: .circle)
            let peg2 = Peg(color: .blue, location: CGPoint(x: 100, y: 90), shape: .circle)
            let peg3 = Peg(color: .blue, location: CGPoint(x: 800, y: 920), shape: .circle)
            let pegSet = Set<Peg>([peg1, peg2, peg3])
            currentGameBoard = GameBoard(name: "game board", pegs: pegSet)
        
        case 2:
            let peg1 = Peg(color: .blue, location: CGPoint(x: 55, y: 66), shape: .circle)
            let peg2 = Peg(color: .blue, location: CGPoint(x: 100, y: 90), shape: .circle)
            let pegSet = Set<Peg>([peg1, peg2])
            currentGameBoard = GameBoard(name: "game board", pegs: pegSet)
        
        case 3:
            let peg1 = Peg(color: .blue, location: CGPoint(x: 55, y: 66), shape: .circle)
            let peg2 = Peg(color: .blue, location: CGPoint(x: 100, y: 90), shape: .circle)
            let peg3 = Peg(color: .blue, location: CGPoint(x: 800, y: 920), shape: .circle)
            let pegSet = Set<Peg>([peg1, peg2, peg3])
            currentGameBoard = GameBoard(name: " ", pegs: pegSet)

        case 4:
            let peg1 = Peg(color: .blue, location: CGPoint(x: 10, y: 20), shape: .circle)
            let peg2 = Peg(color: .blue, location: CGPoint(x: 60, y: 80), shape: .circle)
            let peg3 = Peg(color: .blue, location: CGPoint(x: 500, y: 600), shape: .circle)
            let pegSet = Set<Peg>([peg1, peg2, peg3])
            
            currentGameBoard = GameBoard(name: "new level", pegs: pegSet)
        default:
            currentGameBoard = GameBoard(name: "")
        }
    }
    
    func getCurrentGameBoard() -> GameBoard {
        return currentGameBoard
    }
    
    func changeCurrentGameBoard(newGameBoard: GameBoard) {
        return
    }
    
    func addPegToCurrentGameBoard(color: PegColor, location: CGPoint) -> Bool {
        return true
    }
    
    func removePegFromCurrentGameBoard(at location: CGPoint) -> Bool {
        return true
    }
    
    func updatePegLocation(from start: CGPoint, to end: CGPoint, bottomBoundary: CGFloat) -> Bool {
        return true
    }
    
    func clearCurrentGameBoard() {
        return
    }
    
    func addPegToCurrentGameBoard(color: PegColor, location: CGPoint, shape: Shape) -> Bool {
        return true
    }
    
    func findPegFromLocation(at point: CGPoint) -> Peg? {
        return nil
    }
}
