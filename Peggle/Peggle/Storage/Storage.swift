//
//  Storage.swift
//  Peggle
//
//  Created by Liu Zechu on 30/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation

protocol Storage {
    func saveNewGameBoard(model: LevelDesignerModel) -> Bool
    
    func saveOldGameBoard(model: LevelDesignerModel) -> Bool
    
    func fetchAllLevelNames() -> [String]
    
    func fetchGameBoardByName(name: String) -> GameBoard?
    
    func isFirstGameBoard() -> Bool
    
    func savePreloadedLevels(multiplier: Double)
}
