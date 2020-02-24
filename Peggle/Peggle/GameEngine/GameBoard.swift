//
//  GameBoard.swift
//  Peggle
//
//  Created by Liu Zechu on 25/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint

class GameBoard {
    var name: String
    private(set) var pegs: Set<Peg>
    
    init(name: String) {
        self.name = name
        self.pegs = []
    }
    
    init(name: String, pegs: Set<Peg>) {
        self.name = name
        self.pegs = pegs
    }
    
    /// Adds a peg to this game board.
    /// Returns true if the adding is successful.
    /// Returns false if peg is not successfully added, i.e. overlaps with another peg.
    func addPeg(toAdd: Peg) -> Bool {
        let overlappingPegs = pegs.filter { $0.isOverlapping(with: toAdd) }
        let canAdd = overlappingPegs.isEmpty
        
        if canAdd {
            pegs.insert(toAdd)
            return true
        } else {
            return false
        }
    }
    
    /// Returns a boolean to indicate wether the peg is successfully removed.
    func removePeg(toRemove: Peg) -> Bool {
        let originalCount = pegs.count
        pegs.remove(toRemove)
        
        return pegs.count != originalCount
    }
    
    /// Returns a boolean that indicates whether the specified peg overlaps with any other peg in the game board.
    func pegDoesOverlap(peg: Peg) -> Bool {
        let overlappingPegs = pegs.filter { $0.isOverlapping(with: peg) && $0 != peg }
        return !overlappingPegs.isEmpty
    }
    
    /// Returns the number of pegs of the specified color
    func getNumberOfPegsOfColor(color: PegColor) -> Int {
        let number = pegs.filter { $0.color == color }.count
        return number
    }
    
    func clearAllPegs() {
        pegs = []
    }
    
}
