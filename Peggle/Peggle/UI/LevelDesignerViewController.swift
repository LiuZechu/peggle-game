//
//  ViewController.swift
//  Peggle
//
//  Created by Liu Zechu on 25/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class LevelDesignerViewController: UIViewController {
    var logic: LevelDesignerLogic!

    private var buttonSelected = Button.bluePegSelector
    
    private var initialPegLocation = CGPoint(x: 0, y: 0)
    private var lastPegLocation = CGPoint(x: 0, y: 0)
    var allPegImages: [UIImageView] = []
        
    @IBOutlet private var bluePegSelector: UIButton?
    @IBOutlet private var orangePegSelector: UIButton?
    @IBOutlet private var greenPegSelector: UIButton!
    @IBOutlet private var triangleBluePegSelector: UIButton!
    @IBOutlet private var triangleOrangePegSelector: UIButton!
    @IBOutlet private var triangleGreenPegSelector: UIButton!
    
    private let litUpButtonAlpha: CGFloat = 1.0
    private let dimmedButtonAlpha: CGFloat = 0.5
    
    private var rotationSlider: UISlider?
    private var sizeSlider: UISlider?
    private var pegToAdjust: Peg?
    private var pegImageToAdjust: UIView?
    
    @IBOutlet var levelNameLabel: UILabel! // made public to allow access from extension
    @IBOutlet private var deleteButton: UIButton?
    @IBOutlet private var background: UIImageView?
    @IBOutlet private var backgroundTapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = LevelDesignerModelManager()
        let storage = StorageManager()
        logic = LevelDesignerLogicManager(model: model, storage: storage)
        
        enableBackgroundTap()
        highlightButton(button: .bluePegSelector)
        updateLevelName()
        initialisePreloadedLevels(storage: storage)
        addUpperBorderLine()
    }
    
    private func initialisePreloadedLevels(storage: Storage) {
        let leftBoundary = self.view.frame.minX
        let rightBoundary = self.view.frame.maxX
        let upperBoundary = self.view.frame.minY
        let lowerBoundary = self.view.frame.maxY
        let screenHeight = lowerBoundary - upperBoundary
        let screenWidth = rightBoundary - leftBoundary
        let displayMultiplier = min(screenHeight / MenuScreenViewController.fixedHeight,
                                    screenWidth / MenuScreenViewController.fixedWidth)
        storage.savePreloadedLevels(multiplier: Double(displayMultiplier))
    }
    
    // to prevent placing pegs above the cannon location
    private func addUpperBorderLine() {
        let line = ViewControllerUtility.getBorderLineImageView(height: CGFloat(CannonBall.distanceFromTop),
                                                                width: self.view.frame.maxX)
        self.view.addSubview(line)
    }

    func updateLevelName() {
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
            // check whether the peg is above the upper limit
            guard Double(location.y - Peg.defaultRadius) > CannonBall.distanceFromTop else {
                return
            }
            
            // create a peg and a corresponding image
            guard let imageToAdd = createPeg(at: location) else {
                return
            }
            allPegImages.append(imageToAdd)
            self.view.addSubview(imageToAdd)
        }
        
        // make sliders for another peg disappear upon creating a new peg
        if self.rotationSlider != nil || self.sizeSlider != nil {
            self.rotationSlider?.removeFromSuperview()
            self.sizeSlider?.removeFromSuperview()
            self.rotationSlider = nil
            self.sizeSlider = nil
        }
    }
    
    // These pegs are of default size and rotation angle, which can be changed by the user using sliders
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
                            radius: CGFloat = Peg.defaultRadius, angle: CGFloat = 0.0) -> UIImageView {
        var imageToAdd =
            ViewControllerUtility.createPegImageView(at: location, color: color, shape: shape,
                                                     isGlow: false, radius: radius, angle: angle)
        makeImageResponsiveToTap(image: &imageToAdd)
        makeImageDeletableByLongPress(image: &imageToAdd)
        makeImageDraggable(image: &imageToAdd)
        
        return imageToAdd
    }
    
    // Tapping the image either makes it editable or deletes it, depending on which button is pressed
    private func makeImageResponsiveToTap(image: inout UIImageView) {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(self.handleTapOnPeg))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        image.addGestureRecognizer(tap)
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
    
    @objc private func changePegRotation(_ sender: UISlider) {
        let newAngle = CGFloat(sender.value)
        pegToAdjust?.angleOfRotation = newAngle
        pegImageToAdjust?.removeFromSuperview()
        allPegImages = allPegImages.filter { $0 != pegImageToAdjust }
        // create a peg and a corresponding image
        guard let peg = pegToAdjust else {
            return
        }
        let imageToAdd = createPegImageView(at: peg.location, color: peg.color, shape: peg.shape,
                                            radius: peg.radius, angle: newAngle)
        
        pegImageToAdjust = imageToAdd
        allPegImages.append(imageToAdd)
        self.view.addSubview(imageToAdd)
    }
    
    @objc private func changePegSize(_ sender: UISlider) {
        let newRadius = CGFloat(sender.value)
        pegToAdjust?.radius = newRadius
        pegImageToAdjust?.removeFromSuperview()
        allPegImages = allPegImages.filter { $0 != pegImageToAdjust }
        // create a peg and a corresponding image
        guard let peg = pegToAdjust else {
            return
        }
        let imageToAdd = createPegImageView(at: peg.location, color: peg.color, shape: peg.shape,
                                            radius: peg.radius, angle: peg.angleOfRotation)
        pegImageToAdjust = imageToAdd
        allPegImages.append(imageToAdd)
        self.view.addSubview(imageToAdd)
    }
    
    @objc func handleTapOnPeg(recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        
        if buttonSelected == .deleteButton {
            removePegAndItsView(from: view)
        } else { // make sliders appear so as to edit the peg size/rotation
            let location = view.center
            let pegFound = logic.findPegFromLocation(at: location)
            guard let peg = pegFound else {
                return
            }

            if self.rotationSlider != nil || self.sizeSlider != nil {
                self.rotationSlider?.removeFromSuperview()
                self.sizeSlider?.removeFromSuperview()
                self.rotationSlider = nil
                self.sizeSlider = nil
                return
            }
            
            let sizeSlider = ViewControllerUtility.getSliderForChangingSize(center: self.view.center,
                                                                            initialValue: Float(peg.radius))
            sizeSlider.addTarget(self, action: #selector(self.changePegSize), for: .valueChanged)
            self.sizeSlider = sizeSlider
            self.view.addSubview(sizeSlider)
            
            if peg.shape == .equilateralTriangle {
                let rotationSlider =
                    ViewControllerUtility.getSliderForRotation(center: self.view.center,
                                                               initialValue: Float(peg.angleOfRotation))
                rotationSlider.addTarget(self, action: #selector(self.changePegRotation), for: .valueChanged)
                self.rotationSlider = rotationSlider
                self.view.addSubview(rotationSlider)
            }
            
            // make the peg adjustable
            pegToAdjust = peg
            pegImageToAdjust = view
        }
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
            let bottomBoundary = (background?.frame.maxY ?? 0.0) - Peg.defaultRadius
            let topBoundary = CGFloat(CannonBall.distanceFromTop) + Peg.defaultRadius
            let updateLocationSuccessful = logic.updatePegLocation(from: initialPegLocation, to: lastPegLocation,
                                                                   bottomBoundary: bottomBoundary,
                                                                   topBoundary: topBoundary)
            // make the peg go back if it overlaps with other existing pegs
            // or exceeds the background lower and upper boundaries
            if !updateLocationSuccessful {
                view.center = initialPegLocation
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func goBackToMainMenu(_ sender: UIAlertAction) {
        performSegue(withIdentifier: "backToMainFromDesigner", sender: self)
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
