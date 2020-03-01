//
//  GameViewController+PopUp.swift
//  Peggle
//
//  Created by Liu Zechu on 29/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import UIKit

/// This class handles all the pop-up windows related to `GameViewController`.
extension GameViewController {
    func showInitialPopUp() {
        let alertTitle = "Start Game"
        let alertMessage = "Drag on screen to rotate the Cannon " +
            "and release to launch the ball in that direction. " +
            "Clear all orange pegs with at most 10 balls to win. " +
            "Choose a Powerup below!"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Space Blast", style: .default) { _ in
            self.gameEngine.setPowerUp(powerup: .spaceBlast)
        })
        alert.addAction(UIAlertAction(title: "Spooky Ball", style: .default) { _ in
            self.gameEngine.setPowerUp(powerup: .spookyBall)
        })
        alert.addAction(UIAlertAction(title: "CHAOS MODE", style: .default) { _ in
            self.gameEngine.isChaosMode = true
        })

        self.present(alert, animated: true, completion: nil)
    }
    
    // called after all the pegs are removed
    func showFinalPopUp() {
        let hasWon = gameEngine.hasWon()
        let alertTitle = hasWon ? "You won! You've cleared all the orange pegs"
            : "You lost! You've run out of balls."
        let alertMessage = ""
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Return to Main Menu", style: .cancel) { _ in
            self.returnToMainMenu()
        })

        self.present(alert, animated: true, completion: nil)
    }

    func showAdditionalBallPopUp() {
        let alertTitle = "Good job!"
        let alertMessage = "You've earned an additional ball."
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
        
    @IBAction func handleBackButtonTap(_ sender: Any) {
        let alertTitle = "Return to Main Menu?"
        let alertMessage = "Are you sure to exit? Game progress will not be saved."
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.returnToMainMenu()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
