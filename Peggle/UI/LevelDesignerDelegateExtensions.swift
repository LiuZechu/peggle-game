//
//  LevelDesignerDelegateExtensions.swift
//  Peggle
//
//  Created by Liu Zechu on 29/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import UIKit

extension LevelDesignerViewController: GetGameBoardDelegate {
    func getGameBoard() -> GameBoard {
        return logic.getCurrentGameBoard()
    }
}

extension LevelDesignerViewController: LoadGameBoardDelegate {
    func loadGameBoard(name: String) {
        self.dismiss(animated: true) {
            // clear previous peg images
            for pegImage in self.allPegImages {
                pegImage.removeFromSuperview()
            }
            self.allPegImages = []
            
            for peg in self.logic.getAllPegsInGameBoard(gameBoardName: name) {
                let shape = peg.shape
                let color = peg.color
                let location = peg.location
                let radius = peg.radius
                let angle = CGFloat(peg.angleOfRotation)
                let imageToAdd =
                    self.createPegImageView(at: location, color: color, shape: shape,
                                            radius: radius, angle: angle)
                self.allPegImages.append(imageToAdd)
                self.view.addSubview(imageToAdd)
            }
            self.updateLevelName()
        }
    }
}
