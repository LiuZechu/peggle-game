//
//  Logic.swift
//  Peggle
//
//  Created by Liu Zechu on 30/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

protocol Logic {
    func getCurrentGameBoardName() -> String
    
    func getCurrentGameBoard() -> GameBoard
    
    func nameCurrentGameBoard(name: String)
    
    func addPegToCurrentGameBoard(color: PegColor, location: CGPoint, shape: Shape) -> Bool
    
    func removePegFromCurrentGameBoard(at location: CGPoint) -> Bool
    
    /// Returns false if the new location overlaps with another peg or is out of bounds.
    func updatePegLocation(from start: CGPoint, to end: CGPoint, bottomBoundary: CGFloat) -> Bool
    
    func clearCurrentGameBoard()
    
    /// Saves the current version as a modification to its previously stored game board.
    /// Returns a boolean that indicates whether saving is successful.
    func saveCurrentGameBoard() -> Bool
    
    /// save the current version as a new game board.
    /// Returns a boolean that indicates whether saving is successful.
    func saveNewGameBoard() -> Bool
    
    func fetchAllLevelNames() -> [String]
    
    func fetchGameBoardByName(name: String) -> GameBoard?
    
    //func getColorsAndLocationsOfAllPegs(gameBoardName: String) -> [(PegColor, CGPoint)]
    func getAllPegsInGameBoard(gameBoardName: String) -> Set<Peg>
    
    func isFirstGameBoard() -> Bool
    
    func findPegFromLocation(at point: CGPoint) -> Peg?
}
