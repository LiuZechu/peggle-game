//
//  GetGameBoardDelegate.swift
//  Peggle
//
//  Created by Liu Zechu on 25/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

protocol GetGameBoardDelegate: AnyObject {
    func getGameBoard() -> GameBoard
}
