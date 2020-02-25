//
//  ViewController.swift
//  Peggle
//
//  Created by Liu Zechu on 25/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class LevelDesignerViewController: UIViewController {
    
    private var logic: Logic!
        
    private var buttonSelected = Button.bluePegSelector
    
    private var initialPegLocation = CGPoint(x: 0, y: 0)
    private var lastPegLocation = CGPoint(x: 0, y: 0)
    private var allPegImages: [UIImageView] = []
        
    @IBOutlet private var bluePegSelector: UIButton?
    @IBOutlet private var orangePegSelector: UIButton?
    @IBOutlet private var greenPegSelector: UIButton!
    @IBOutlet private var triangleBluePegSelector: UIButton!
    @IBOutlet private var triangleOrangePegSelector: UIButton!
    @IBOutlet private var triangleGreenPegSelector: UIButton!
    
    private let litUpButtonAlpha: CGFloat = 1.0
    private let dimmedButtonAlpha: CGFloat = 0.5
    
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
        highlightButton(button: .bluePegSelector)
        updateLevelName()
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
    
    // This function makes the selected button brighter while making the rest dimmer.
    private func highlightButton(button: Button) {
        bluePegSelector?.alpha = dimmedButtonAlpha
        orangePegSelector?.alpha = dimmedButtonAlpha
        greenPegSelector?.alpha = dimmedButtonAlpha
        triangleBluePegSelector?.alpha = dimmedButtonAlpha
        triangleOrangePegSelector?.alpha = dimmedButtonAlpha
        triangleGreenPegSelector?.alpha = dimmedButtonAlpha
        deleteButton?.alpha = dimmedButtonAlpha
        
        switch button {
        case .bluePegSelector:
            bluePegSelector?.alpha = litUpButtonAlpha
        case .orangePegSelector:
            orangePegSelector?.alpha = litUpButtonAlpha
        case .greenPegSelector:
            greenPegSelector?.alpha = litUpButtonAlpha
        case .triangleBluePegSelector:
            triangleBluePegSelector?.alpha = litUpButtonAlpha
        case .triangleOrangePegSelector:
            triangleOrangePegSelector?.alpha = litUpButtonAlpha
        case .triangleGreenPegSelector:
            triangleGreenPegSelector?.alpha = litUpButtonAlpha
        case .deleteButton:
            deleteButton?.alpha = litUpButtonAlpha
        }
    }
    
    @IBAction private func handleBluePegSelectorTap() {
        buttonSelected = .bluePegSelector
        highlightButton(button: .bluePegSelector)
    }
    
    @IBAction private func handleOrangePegSelectorTap() {
        buttonSelected = .orangePegSelector
        highlightButton(button: .orangePegSelector)
    }
    
    @IBAction private func handleDeleteButtonTap() {
        buttonSelected = .deleteButton
        highlightButton(button: .deleteButton)
    }
    
    @IBAction private func handleGreenPegSelectorTap(_ sender: Any) {
        buttonSelected = .greenPegSelector
        highlightButton(button: .greenPegSelector)
    }
    
    @IBAction private func handleTriangleBluePegSelectorTap(_ sender: Any) {
        buttonSelected = .triangleBluePegSelector
        highlightButton(button: .triangleBluePegSelector)
    }
    
    @IBAction private func handleTriangleOrangePegSelectorTap(_ sender: Any) {
        buttonSelected = .triangleOrangePegSelector
        highlightButton(button: .triangleOrangePegSelector)
    }
    
    @IBAction private func handleTriangleGreenPegSelectorTap(_ sender: Any) {
        buttonSelected = .triangleGreenPegSelector
        highlightButton(button: .triangleGreenPegSelector)
    }
    
    @IBAction private func handleSaveButtonTap() {
        showNameLevelDialogue()
    }

    func clearAllPegs(_ sender: UIAlertAction) {
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
        let pegColor: PegColor
        switch buttonSelected {
        case .bluePegSelector, .triangleBluePegSelector:
            pegColor = .blue
        case .orangePegSelector, .triangleOrangePegSelector:
            pegColor = .orange
        case .greenPegSelector, .triangleGreenPegSelector:
            pegColor = .green
        case .deleteButton:
            return nil
        }
        
        let pegShape: Shape
        switch buttonSelected {
        case .bluePegSelector, .orangePegSelector, .greenPegSelector:
            pegShape = .circle
        case .triangleBluePegSelector, .triangleOrangePegSelector, .triangleGreenPegSelector:
            pegShape = .equilateralTriangle
        case .deleteButton:
            return nil
        }
        
        let imageToAdd = createPegImageView(at: location, color: pegColor, shape: pegShape)
       
        let pegAddedSuccessfully =
            logic.addPegToCurrentGameBoard(color: pegColor, location: imageToAdd.center, shape: pegShape)
        
        return pegAddedSuccessfully ? imageToAdd : nil
    }
    
    /// Creates a peg's image at corresponding location on the screen, with the specified color.
    func createPegImageView(at location: CGPoint, color: PegColor, shape: Shape,
                            radius: CGFloat = Peg.defaultRadius) -> UIImageView {
        let frame = CGRect(x: location.x - radius, y: location.y - radius,
                           width: radius * 2, height: radius * 2)
        var imageToAdd = UIImageView(frame: frame)
        imageToAdd.layer.cornerRadius = radius
        imageToAdd.contentMode = .scaleAspectFit
        imageToAdd.isUserInteractionEnabled = true
        
        if color == .blue {
            if shape == .circle {
                imageToAdd.image = UIImage(named: "peg-blue")
            } else {
                imageToAdd.image = UIImage(named: "peg-blue-triangle")
            }
        } else if color == .orange {
            if shape == .circle {
                imageToAdd.image = UIImage(named: "peg-orange")
            } else {
                imageToAdd.image = UIImage(named: "peg-orange-triangle")
            }
        } else {
            if shape == .circle {
                imageToAdd.image = UIImage(named: "peg-green")
            } else {
                imageToAdd.image = UIImage(named: "peg-green-triangle")
            }
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
        guard buttonSelected == .deleteButton else {
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
    
//    @IBAction private func handleResetButtonTap() {
//        let alertTitle = "Reset game board"
//        let alertMessage = "Would you like to clear all the pegs on this game board?"
//        let alert = UIAlertController(title: alertTitle, message: alertMessage,
//                                      preferredStyle: UIAlertController.Style.alert)
//
//        // add the actions (buttons)
//        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.default, handler: self.clearAllPegs))
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
//
//        self.present(alert, animated: true, completion: nil)
//    }
    
//    @IBAction private func handleBackButtonTap(_ sender: Any) {
//        let alertTitle = "Return to Main Menu"
//        let alertMessage = "Are you sure you want to exit? Any unsaved work will be lost."
//        let alert = UIAlertController(title: alertTitle, message: alertMessage,
//                                      preferredStyle: UIAlertController.Style.alert)
//
//        // add the actions (buttons)
//        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default,
//                                      handler: self.goBackToMainMenu))
//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
//
//        self.present(alert, animated: true, completion: nil)
//    }
    
    func goBackToMainMenu(_ sender: UIAlertAction) {
        performSegue(withIdentifier: "backToMainFromDesigner", sender: self)
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
    
    @IBAction private func startGame(_ sender: UIButton) {
        // something
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAllLevelNames" {
            if let levelTableViewController: LevelTableViewController =
                segue.destination as? LevelTableViewController {
                levelTableViewController.delegate = self
                levelTableViewController.logic = logic
            }
        } else if segue.identifier == "startGame" {
            if let gameViewCongtroller: GameViewController =
                segue.destination as? GameViewController {
                gameViewCongtroller.delegate = self
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

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
            
            // create all the new peg images
            // let pegColorsAndLocations = self.logic.getColorsAndLocationsOfAllPegs(gameBoardName: name)
            for peg in self.logic.getAllPegsInGameBoard(gameBoardName: name) {
                let shape = peg.shape
                let color = peg.color
                let location = peg.location
                let imageToAdd = self.createPegImageView(at: location, color: color, shape: shape)
                
                self.allPegImages.append(imageToAdd)
                self.view.addSubview(imageToAdd)
            }
            
            self.updateLevelName()
        }
    }
}
