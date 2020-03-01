//
//  LevelDesignerLogicManager.swift
//  Peggle
//
//  Created by Liu Zechu on 27/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

class LevelDesignerLogicManager: LevelDesignerLogic {
    private var model: LevelDesignerModel
    private var storage: Storage
    
    init(model: LevelDesignerModel, storage: Storage) {
        self.model = model
        self.storage = storage
    }
    
    func getCurrentGameBoard() -> GameBoard {
        return model.getCurrentGameBoard()
    }
    
    func isFirstGameBoard() -> Bool {
        return storage.isFirstGameBoard()
    }
    
    func addPegToCurrentGameBoard(color: PegColor, location: CGPoint, shape: Shape) -> Bool {
        return model.addPegToCurrentGameBoard(color: color, location: location, shape: shape)
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
    
    func getAllPegsInGameBoard(gameBoardName: String) -> Set<Peg> {
        let gameBoard = fetchGameBoardByName(name: gameBoardName)
        return gameBoard?.pegs ?? Set<Peg>()
    }
    
    func findPegFromLocation(at point: CGPoint) -> Peg? {
        return model.findPegFromLocation(at: point)
    }
}
