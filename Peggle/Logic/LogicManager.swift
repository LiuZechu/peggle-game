//
//  LogicManager.swift
//  Peggle
//
//  Created by Liu Zechu on 27/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

class LogicManager: Logic {
    private var model: Model
    private var storage: Storage
    
    init(model: Model, storage: Storage) {
        self.model = model
        self.storage = storage
    }
    
    func getCurrentGameBoard() -> GameBoard {
        return model.getCurrentGameBoard()
    }
    
    func isFirstGameBoard() -> Bool {
        return storage.isFirstGameBoard()
    }
    
    func addPegToCurrentGameBoard(color: PegColor, location: CGPoint) -> Bool {
        return model.addPegToCurrentGameBoard(color: color, location: location)
    }
    
    func removePegFromCurrentGameBoard(at location: CGPoint) -> Bool {
        return model.removePegFromCurrentGameBoard(at: location)
    }
    
    func updatePegLocation(from start: CGPoint, to end: CGPoint, bottomBoundary: CGFloat) -> Bool {
        return model.updatePegLocation(from: start, to: end, bottomBoundary: bottomBoundary)
    }
    
    func clearCurrentGameBoard() {
        model.clearCurrentGameBoard()
    }
    
    func saveCurrentGameBoard() -> Bool {
        return storage.saveOldGameBoard(model: model)
    }
    
    func saveNewGameBoard() -> Bool {
        return storage.saveNewGameBoard(model: model)
    }
        
    func getCurrentGameBoardName() -> String {
        return model.getCurrentGameBoard().name
    }
    
    func nameCurrentGameBoard(name: String) {
        model.getCurrentGameBoard().name = name
    }
        
    func fetchAllLevelNames() -> [String] {
        return storage.fetchAllLevelNames()
    }
    
    func fetchGameBoardByName(name: String) -> GameBoard? {
        if let newGameBoard = storage.fetchGameBoardByName(name: name) {
            model.changeCurrentGameBoard(newGameBoard: newGameBoard)
            return newGameBoard
        } else {
            return nil
        }
    }
    
    func getColorsAndLocationsOfAllPegs(gameBoardName: String) -> [(PegColor, CGPoint)] {
        let gameBoard = fetchGameBoardByName(name: gameBoardName)
        var pegColorsAndLocations = [(PegColor, CGPoint)]()
        for peg in gameBoard?.pegs ?? [] {
            let color = peg.color
            let location = peg.location
            pegColorsAndLocations.append((color, location))
        }
        
        return pegColorsAndLocations
    }
}
