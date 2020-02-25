//
//  ViewController.swift
//  Peggle
//
//  Created by Liu Zechu on 25/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var logic: Logic!
        
    private var isBlueSelected = true
    private var isOrangeSelected = false
    private var isDeleteButtonSelected = false
    
    private var initialPegLocation = CGPoint(x: 0, y: 0)
    private var lastPegLocation = CGPoint(x: 0, y: 0)
    private var allPegImages: [UIImageView] = []
        
    @IBOutlet private var bluePegSelector: UIButton?
    @IBOutlet private var orangePegSelector: UIButton?
    @IBOutlet private var deleteButton: UIButton?
    @IBOutlet private var levelNameLabel: UILabel!
    @IBOutlet private var background: UIImageView?
    @IBOutlet private var backgroundTapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = ModelManager()
        let storage = StorageManager()
        logic = LogicManager(model: model, storage: storage)
        
        enableBackgroundTap()
        initialiseButtonAlphas()
        updateLevelName()
    }
    
    private func initialiseButtonAlphas() {
        bluePegSelector?.alpha = 1
        orangePegSelector?.alpha = 0.5
        deleteButton?.alpha = 0.5
    }
    
    private func updateLevelName() {
        levelNameLabel.text = logic.getCurrentGameBoardName()
    }
    
    private func enableBackgroundTap() {
        let singleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(self.handleBackgroundTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.background?.addGestureRecognizer(singleTap)
        self.background?.isUserInteractionEnabled = true
    }
    
    @IBAction private func handleBluePegSelectorTap() {
        isBlueSelected = true
        isDeleteButtonSelected = false
        isOrangeSelected = false
        
        bluePegSelector?.alpha = 1
        orangePegSelector?.alpha = 0.5
        deleteButton?.alpha = 0.5
    }
    
    @IBAction private func handleOrangePegSelectorTap() {
        isOrangeSelected = true
        isDeleteButtonSelected = false
        isBlueSelected = false
        
        bluePegSelector?.alpha = 0.5
        orangePegSelector?.alpha = 1
        deleteButton?.alpha = 0.5
    }
    
    @IBAction private func handleDeleteButtonTap() {
        isDeleteButtonSelected = true
        isBlueSelected = false
        isOrangeSelected = false
        
        bluePegSelector?.alpha = 0.5
        orangePegSelector?.alpha = 0.5
        deleteButton?.alpha = 1
    }
    
    @IBAction private func handleSaveButtonTap() {
        showNameLevelDialogue()
    }

    private func clearAllPegs(_ sender: UIAlertAction) {
        logic.clearCurrentGameBoard()
        for pegImage in allPegImages {
            pegImage.removeFromSuperview()
        }
    }

    @objc func handleBackgroundTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            guard let location: CGPoint = backgroundTapGesture?.location(in: nil) else {
                return
            }
            // create a peg and a corresponding image
            guard let imageToAdd = createPeg(at: location) else {
                return
            }
            
            allPegImages.append(imageToAdd)
            self.view.addSubview(imageToAdd)
        }
    }
    
    private func createPeg(at location: CGPoint) -> UIImageView? {
        guard isBlueSelected != isOrangeSelected else {
            return nil
        }
        
        let pegColor = isBlueSelected ? PegColor.blue : PegColor.orange
        let imageToAdd = createPegImageView(at: location, color: pegColor)
       
        let pegAddedSuccessfully =
            logic.addPegToCurrentGameBoard(color: pegColor, location: imageToAdd.center)
        
        return pegAddedSuccessfully ? imageToAdd : nil
    }
    
    /// Creates a peg's image at corresponding location on the screen, with the specified color.
    func createPegImageView(at location: CGPoint, color: PegColor) -> UIImageView {
        let frame = CGRect(x: location.x - Peg.radius, y: location.y - Peg.radius,
                           width: Peg.radius * 2, height: Peg.radius * 2)
        var imageToAdd = UIImageView(frame: frame)
        imageToAdd.layer.cornerRadius = Peg.radius
        imageToAdd.contentMode = .scaleAspectFit
        imageToAdd.isUserInteractionEnabled = true
        
        if color == .blue {
            imageToAdd.image = UIImage(named: "peg-blue")
        } else {
            imageToAdd.image = UIImage(named: "peg-orange")
        }
        
        makeImageDeletableByTap(image: &imageToAdd)
        makeImageDeletableByLongPress(image: &imageToAdd)
        makeImageDraggable(image: &imageToAdd)
        
        return imageToAdd
    }
    
    private func makeImageDeletableByTap(image: inout UIImageView) {
        let deleteTap = UITapGestureRecognizer(target: self,
                                               action: #selector(self.handleDeleteTap))
        deleteTap.numberOfTapsRequired = 1
        deleteTap.numberOfTouchesRequired = 1
        image.addGestureRecognizer(deleteTap)
    }
    
    private func makeImageDeletableByLongPress(image: inout UIImageView) {
        let deletionByLongPress =
            UILongPressGestureRecognizer(target: self,
                                         action: #selector(self.handleDeleteLongPress))
        image.addGestureRecognizer(deletionByLongPress)
    }
    
    private func makeImageDraggable(image: inout UIImageView) {
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePegDrag))
        image.addGestureRecognizer(dragRecognizer)
    }
    
    @objc func handleDeleteTap(recognizer: UIPanGestureRecognizer) {
        guard isDeleteButtonSelected else {
            return
        }
        guard let view = recognizer.view else {
            return
        }
        
        removePegAndItsView(from: view)
    }
    
    private func removePegAndItsView(from view: UIView) {
        let isRemoveSuccessful = logic.removePegFromCurrentGameBoard(at: view.center)
        if isRemoveSuccessful {
            view.removeFromSuperview()
        }
    }
    
    @objc func handleDeleteLongPress(recognizer: UILongPressGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        removePegAndItsView(from: view)
    }

    @objc func handlePegDrag(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        guard let view = recognizer.view else {
            return
        }
        
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        
        if recognizer.state == .began {
            initialPegLocation = view.center
            lastPegLocation = view.center
        } else if recognizer.state == .ended {
            lastPegLocation = view.center
            
            // update the peg's location
            let bottomBoundary = background?.frame.maxY ?? 0.0
            let updateLocationSuccessful = logic.updatePegLocation(from: initialPegLocation, to: lastPegLocation,
                                                                   bottomBoundary: bottomBoundary)
            
            // make the peg go back if it overlaps with other existing pegs
            // or exceeds the background bottom boundary
            if !updateLocationSuccessful {
                view.center = initialPegLocation
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
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
        let isNameEmpty = logic.getCurrentGameBoardName().trimmingCharacters(in: .whitespaces).isEmpty
        if !logic.isFirstGameBoard() && !isNameEmpty {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAllLevelNames" {
            if let levelTableViewController: LevelTableViewController =
                segue.destination as? LevelTableViewController {
                levelTableViewController.delegate = self
                levelTableViewController.logic = logic
            }
        }
    }
    
}

extension ViewController: LoadGameBoardDelegate {
    func loadGameBoard(name: String) {
        self.dismiss(animated: true) {
            // clear previous peg images
            for pegImage in self.allPegImages {
                pegImage.removeFromSuperview()
            }
            self.allPegImages = []
            
            // create all the new peg images
            let pegColorsAndLocations = self.logic.getColorsAndLocationsOfAllPegs(gameBoardName: name)
            for pegTuple in pegColorsAndLocations {
                // a peg tuple is of type (Color, CGPoint)
                // This is used instead of actual Peg objects to avoid breaking abstraction,
                // as ViewController should not know about Peg
                let color = pegTuple.0
                let location = pegTuple.1
                let imageToAdd = self.createPegImageView(at: location, color: color)
                
                self.allPegImages.append(imageToAdd)
                self.view.addSubview(imageToAdd)
            }
            
            self.updateLevelName()
        }
    }
}
