//
//  Model.swift
//  Peggle
//
//  Created by Liu Zechu on 30/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

protocol Model {
    
    func getCurrentGameBoard() -> GameBoard
    
    func changeCurrentGameBoard(newGameBoard: GameBoard)
    
    func addPegToCurrentGameBoard(color: PegColor, location: CGPoint, shape: Shape) -> Bool
    
    func removePegFromCurrentGameBoard(at location: CGPoint) -> Bool
    
    /// Updates a peg's location.
    /// Returns true if the update is successful.
    /// Returns false if the new location overlaps with another peg or is out of bounds.
    func updatePegLocation(from start: CGPoint, to end: CGPoint, bottomBoundary: CGFloat) -> Bool
    
    func clearCurrentGameBoard()
    
    func findPegFromLocation(at point: CGPoint) -> Peg?
}
