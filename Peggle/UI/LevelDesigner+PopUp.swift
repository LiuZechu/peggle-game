//
//  LevelDesignerAlertManager.swift
//  Peggle
//
//  Created by Liu Zechu on 25/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

/// This extension handles the popup windows.
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
    
    func showNameLevelDialogue() {
        let alertTitle = "Enter level name"
        let alertMessage = "Or rename the current level"
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        // "new level" action creates a new level
        let newLevelAction = UIAlertAction(title: "New Level", style: .default) { _ in
            //getting the input string from user
            let name = alertController.textFields?[0].text
            self.handlePopUpSaveAction(name: name, isNewGameBoard: true)
        }

        // "edit current" action modifies the current level
        let editCurrentAction = UIAlertAction(title: "Edit Current Level", style: .default) { _ in
            //getting the input string from user
            let name = alertController.textFields?[0].text
            self.handlePopUpSaveAction(name: name, isNewGameBoard: false)
        }

        //cancel action does nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }

        alertController.addTextField { textField in
            textField.placeholder = "Enter Level Name"
            textField.text = self.logic.getCurrentGameBoardName()
        }

        alertController.addAction(newLevelAction)
        let name = logic.getCurrentGameBoardName()
        let isNameEmpty = name.trimmingCharacters(in: .whitespaces).isEmpty
        // Disallow modifying/overriding preloaded levels
        let isNameReserved = SampleLevelsLoader.reservedNames.contains(name)
        if !logic.isFirstGameBoard() && !isNameEmpty && !isNameReserved {
            alertController.addAction(editCurrentAction)
        }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Saves user's game board and checks for validity of name.
    private func handlePopUpSaveAction(name: String?, isNewGameBoard: Bool) {
        let originalName = logic.getCurrentGameBoardName()
        logic.nameCurrentGameBoard(name: name ?? "[unnamed]")
        
        var saveSuccessful: Bool
        if isNewGameBoard {
            saveSuccessful = logic.saveNewGameBoard()
        } else {
            saveSuccessful = logic.saveCurrentGameBoard()
        }
        if saveSuccessful {
            levelNameLabel.text = name
            showSaveSuccessPopUp()
        } else {
            logic.nameCurrentGameBoard(name: originalName)
            showNameAlreadyExistsPopUp()
        }
    }
    
    private func showSaveSuccessPopUp() {
        let alertTitle = "Save successful"
        let alertMessage = "\"\(logic.getCurrentGameBoardName())\" is saved successfully!"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNameAlreadyExistsPopUp() {
        let alertTitle = "Choose another name"
        let alertMessage = "The name \"\(logic.getCurrentGameBoardName())\""
            + " is empty or already exists!"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

        // add the actions (buttons)
        let renameAction = UIAlertAction(title: "Rename", style: .default) { _ in
            self.showNameLevelDialogue()
        }
        alert.addAction(renameAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
