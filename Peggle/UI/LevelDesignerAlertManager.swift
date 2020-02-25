//
//  LevelDesignerAlertManager.swift
//  Peggle
//
//  Created by Liu Zechu on 25/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

extension LevelDesignerViewController {
    @IBAction private func handleResetButtonTap() {
        let alertTitle = "Reset game board"
        let alertMessage = "Would you like to clear all the pegs on this game board?"
        let alert = UIAlertController(title: alertTitle, message: alertMessage,
                                      preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: self.clearAllPegs))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func handleBackButtonTap(_ sender: Any) {
        let alertTitle = "Return to Main Menu"
        let alertMessage = "Are you sure you want to exit? Any unsaved work will be lost."
        let alert = UIAlertController(title: alertTitle, message: alertMessage,
                                      preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default,
                                      handler: self.goBackToMainMenu))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    
}
