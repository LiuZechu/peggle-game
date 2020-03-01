//
//  GameModel.swift
//  Peggle
//
//  Created by Liu Zechu on 27/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

class LevelDesignerModelManager: LevelDesignerModel {

    private var currentGameBoard: GameBoard
    
    init() {
        currentGameBoard = GameBoard(name: "")
    }
    
    func getCurrentGameBoard() -> GameBoard {
        return currentGameBoard
    }
    
    func changeCurrentGameBoard(newGameBoard: GameBoard) {
        currentGameBoard = newGameBoard
    }
    
    func addPegToCurrentGameBoard(color: PegColor, location: CGPoint, shape: Shape) -> Bool {
        let peg = Peg(color: color, location: location, shape: shape)
        return currentGameBoard.addPeg(toAdd: peg)
    }
    
    func removePegFromCurrentGameBoard(at location: CGPoint) -> Bool {
        if let peg = findPegFromLocation(at: location) {
            return currentGameBoard.removePeg(toRemove: peg)
        } else {
            return false
        }
    }
    
    /// Returns false if peg not found or new location overlaps with other pegs or out of bounds.
    func updatePegLocation(from start: CGPoint, to end: CGPoint,
                           bottomBoundary: CGFloat, topBoundary: CGFloat) -> Bool {
        guard let peg = findPegFromLocation(at: start) else {
            return false
        }
        
        peg.location = end
        
        // checks whether it overlaps with other existing pegs on the board,
        // or whether it exceeds bottom/top boundaries.
        let exceedsBoundary = end.y > bottomBoundary || end.y < topBoundary
        if exceedsBoundary || currentGameBoard.pegDoesOverlap(peg: peg) {
            peg.location = start
            return false
        } else {
            return true
        }
    }
    
    func findPegFromLocation(at point: CGPoint) -> Peg? {
        let pegSet = currentGameBoard.pegs.filter {
            let isXWithinRange = abs($0.location.x - point.x) < Peg.defaultRadius
            let isYWithinRange = abs($0.location.y - point.y) < Peg.defaultRadius
            return isXWithinRange && isYWithinRange
        }
        
        return pegSet.first
    }
    
    func clearCurrentGameBoard() {
        currentGameBoard.clearAllPegs()
    }
    
}
