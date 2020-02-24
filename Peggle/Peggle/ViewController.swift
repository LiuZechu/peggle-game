//
//  ViewController.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 8/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, Renderer {
    
    private var gameEngine: PeggleGameEngine!
    
    private var isLaunchable: Bool = true // indicates whether the cannon ball is ready to be launched now
    private var isRestarted = false // indicates whether the previous game loop has ended and a new ball replenished
    
    @IBOutlet private var cannonImageView: UIImageView!
    @IBOutlet private var ballsNumberLabel: UILabel!
    @IBOutlet private var background: UIImageView!
    private var ballImageView: UIImageView!
    private var bucketImageView: UIImageView!
    private var pegImages: [UIImageView] = []
    private var glowPegImages: [UIImageView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameEngine = PeggleGameEngine(leftBoundary: Double(self.view.frame.minX),
                                      rightBoundary: Double(self.view.frame.maxX),
                                      upperBoundary: Double(self.view.frame.minY),
                                      lowerBoudary: Double(self.view.frame.maxY))
        gameEngine.addRenderer(renderer: self)
        addDefaultPegImages()
        enableBackgroundTapForLaunch()
        gameEngine.setBallYPosition(yPosition: Double(cannonImageView.center.y))
        addBallToScreen()
        addBucketToScreen()
        updateBallsNumberLabel()
        
        // make cannon on top of ball
        self.view.bringSubviewToFront(cannonImageView)
        
        // rotation of cannon
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePegDrag))
        self.view.addGestureRecognizer(dragRecognizer)
        
        // try out rotation
        // cannonImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showInitialPopUp()
    }
    
    private func addBallToScreen() {
        let ballImage = UIImage(named: "ball")
        let location = gameEngine.getBallLocation()
        let frame = CGRect(x: location.x - CGFloat(CannonBall.radius),
                           y: location.y - CGFloat(CannonBall.radius),
                           width: CGFloat(CannonBall.radius) * 2,
                           height: CGFloat(CannonBall.radius) * 2)
        let ballViewToAdd = UIImageView(frame: frame)
        ballViewToAdd.layer.cornerRadius = Peg.radius
        ballViewToAdd.contentMode = .scaleAspectFit
        ballViewToAdd.image = ballImage
        self.view.addSubview(ballViewToAdd)
        
        ballImageView = ballViewToAdd
    }
    
    // for adjusting the cannon angle for launch
    @objc func handlePegDrag(recognizer: UIPanGestureRecognizer) {
        guard isLaunchable else {
            return
        }
        
        let cannonLocation = cannonImageView.center
        
        if recognizer.state == .began {
            let touchLocation = recognizer.location(in: nil)
            let angleOfRotation = calculateAngleOfRotation(cannonLocation: cannonLocation,
                                                           touchLocation: touchLocation)
            cannonImageView.transform = CGAffineTransform(rotationAngle: angleOfRotation)
            
        } else if recognizer.state == .ended {
//            let touchLocation = recognizer.location(in: nil)
//            let angleOfRotation = calculateAngleOfRotation(cannonLocation: cannonLocation,
//                                                           touchLocation: touchLocation)
//            cannonImageView.transform = CGAffineTransform(rotationAngle: angleOfRotation)
            
            let tapLocation = recognizer.location(in: nil)
            let ballLocation = gameEngine.getBallLocation()
            let xDifference = tapLocation.x - ballLocation.x
            let yDifference = tapLocation.y - ballLocation.y
            
            var launchAngle = Double(atan(yDifference / xDifference))
            
            if yDifference < 0 {
                if xDifference > 0 {
                    launchAngle = -Double.pi / 2
                } else {
                    launchAngle = Double.pi / 2
                }
            }
            
            // launch the ball
            gameEngine.launchCannonBall(angle: launchAngle, initialSpeed: PeggleGameEngine.initialBallSpeed)
            isLaunchable = false
            isRestarted = false
        }

        let touchLocation = recognizer.location(in: nil)
        let angleOfRotation = calculateAngleOfRotation(cannonLocation: cannonLocation,
                                                       touchLocation: touchLocation)
        cannonImageView.transform = CGAffineTransform(rotationAngle: angleOfRotation)
    }
    
    private func calculateAngleOfRotation(cannonLocation: CGPoint,
                                          touchLocation: CGPoint) -> CGFloat {

        let xDifference = touchLocation.x - cannonLocation.x
        let yDifference = touchLocation.y - cannonLocation.y
        
        // prevent tapping above the cannon
        guard yDifference > 0 else {
            if xDifference > 0 {
                return -CGFloat.pi / 2
            } else {
                return CGFloat.pi / 2
            }
        }
        
        let angleFromHorizontal = Double(atan(yDifference / xDifference))
        let angleOfRotation: Double
        
        if angleFromHorizontal > 0 {
            angleOfRotation = -(Double.pi / 2 - angleFromHorizontal)
        } else {
            angleOfRotation = Double.pi / 2 + angleFromHorizontal
        }
        
        return CGFloat(angleOfRotation)
    }
    
//    private func addCannonToScreen() {
//        let cannonImage = UIImage(named: "cannon")
//        let location = gameEngine.getBallLocation()
//        let frame = CGRect(x: location.x - CGFloat(CannonBall.radius),
//                           y: location.y - CGFloat(CannonBall.radius),
//                           width: CGFloat(CannonBall.radius) * 2,
//                           height: CGFloat(CannonBall.radius) * 2)
//        let cannonViewToAdd = UIImageView(frame: frame)
//        cannonViewToAdd.layer.cornerRadius = Peg.radius
//        cannonViewToAdd.contentMode = .scaleAspectFit
//        cannonViewToAdd.image = cannonImage
//        self.view.addSubview(cannonViewToAdd)
//
//        ballImageView = cannonViewToAdd
//    }
    
    private func addBucketToScreen() {
        let bucketImage = UIImage(named: "bucket")
        let location = gameEngine.getBucketBottomCenterLocation()
        // hard code for now
        let frame = CGRect(x: location.x - CGFloat(150 / 2),
                           y: location.y - CGFloat(150),
                           width: 150,
                           height: 150)
        let bucketViewToAdd = UIImageView(frame: frame)
        //bucketViewToAdd.layer.cornerRadius = Peg.radius
        bucketViewToAdd.contentMode = .scaleAspectFit
        bucketViewToAdd.image = bucketImage
        self.view.addSubview(bucketViewToAdd)
        
        bucketImageView = bucketViewToAdd
    }
    
    // To enable the user to choose the angle at which the ball will be launched
    private func enableBackgroundTapForLaunch() {
        let singleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(self.handleBackgroundTapForLaunch))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.background?.addGestureRecognizer(singleTap)
        self.background?.isUserInteractionEnabled = true
    }
    
    @objc func handleBackgroundTapForLaunch(sender: UITapGestureRecognizer) {
        if sender.state == .ended && isLaunchable {
            let tapLocation = sender.location(in: nil)
            let ballLocation = gameEngine.getBallLocation()
            let xDifference = tapLocation.x - ballLocation.x
            let yDifference = tapLocation.y - ballLocation.y
            
            // prevent tapping above the cannon
            guard yDifference > 0 else {
                return
            }
            
            let launchAngle = Double(atan(yDifference / xDifference))
            
            // ONLY THE FOLLOWING COPIED TO THE NEW ROTATION LAUNCH METHOD
            gameEngine.launchCannonBall(angle: launchAngle, initialSpeed: PeggleGameEngine.initialBallSpeed)
            isLaunchable = false
            isRestarted = false
        }
    }

    private func addDefaultPegImages() {
        let pegs = gameEngine.getAllPegs()
        for peg in pegs {
            let pegImage = createPegImageView(at: peg.location, color: peg.color, isGlow: false)
            self.view.addSubview(pegImage)
            pegImages.append(pegImage)
        }
    }
    
    /// Creates a peg's image at corresponding location on the screen, with the specified color.
    func createPegImageView(at location: CGPoint, color: PegColor, isGlow: Bool) -> UIImageView {
        let frame = CGRect(x: location.x - Peg.radius, y: location.y - Peg.radius,
                           width: Peg.radius * 2, height: Peg.radius * 2)
        let imageToAdd = UIImageView(frame: frame)
        imageToAdd.layer.cornerRadius = frame.height / 2
        imageToAdd.layer.masksToBounds = true
        imageToAdd.contentMode = .scaleAspectFit
        
        if color == .blue {
            if isGlow {
                imageToAdd.image = UIImage(named: "peg-blue-glow")
            } else {
                imageToAdd.image = UIImage(named: "peg-blue")
            }
        } else {
            if isGlow {
                imageToAdd.image = UIImage(named: "peg-orange-glow")
            } else {
                imageToAdd.image = UIImage(named: "peg-orange")
            }
        }

        return imageToAdd
    }
    
    private func deleteAllGlowingPegs() {
        for image in glowPegImages {
            animateRemovalOfPeg(pegImage: image)
            removePegAndItsView(from: image)
        }
        
        glowPegImages = []
        
        // after all the deletions, restart the round
        Timer.scheduledTimer(timeInterval: TimeInterval(2.2), target: self,
                             selector: #selector(restart), userInfo: nil, repeats: false)
    }
    
    private func animateRemovalOfPeg(pegImage: UIImageView) {
        UIView.animate(withDuration: 2) {
            pegImage.alpha = 0
        }
    }

    private func removePegAndItsView(from view: UIView) {
        let isRemoveSuccessful = gameEngine.removePegFromCurrentGameBoard(at: view.center)
        if isRemoveSuccessful {
            view.removeFromSuperview()
            pegImages = pegImages.filter { $0 != view }
        }
    }
    
    // End the previous game loop and replenish the cannon ball
    @objc private func restart() {
        gameEngine.restartAnotherRound()
        ballImageView.center = gameEngine.getBallLocation()
        isLaunchable = true
        
        // update the ball number
        updateBallsNumberLabel()
        
        // If the player has won/lost, restart another round
        if gameEngine.hasWon() || gameEngine.hasLost() {
            showFinalPopUp()
        }
    }
    
    func render() {
        // move ball
        ballImageView.center = gameEngine.getBallLocation()
        
        // move bucket
        let newBucketLocationX = gameEngine.getBucketBottomCenterLocation().x
        let newBucketLocationY = gameEngine.getBucketBottomCenterLocation().y - 150 / 2
        bucketImageView.center = CGPoint(x: newBucketLocationX, y: newBucketLocationY)
        
        // light up pegs hit
        for peg in gameEngine.getPegsHit() {
            for image in pegImages where image.containsLocation(location: peg.location, circleRadius: Peg.radius) {
                let center = image.center
                image.removeFromSuperview()
                let glowImage = createPegImageView(at: center, color: peg.color, isGlow: true)
                self.view.addSubview(glowImage)
                glowPegImages.append(glowImage)
            }
        }
        
        // delete pegs when ball flies out
        if gameEngine.isBallOutOfBounds() && !isRestarted {
            deleteAllGlowingPegs()
            isRestarted = true
        }
        
        // show additional ball popup
        if gameEngine.isBallInsideBucket() {
            showAdditionalBallPopUp()
        }
    }
    
    // update the text on top right hand corner of the background
    private func updateBallsNumberLabel() {
        ballsNumberLabel.text = "Balls left: \(gameEngine.numberOfBallsLeft)"
    }
    
    private func showInitialPopUp() {
        let alertTitle = "Start Game"
        let alertMessage = "Tap anywhere below the grey ball to launch the ball in that direction. Have fun!"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    // called after all the pegs are removed
    private func showFinalPopUp() {
        let hasWon = gameEngine.hasWon()
        let alertTitle = hasWon ? "You won! You've cleared all the orange pegs" : "You lost! You've run out of balls."
        let alertMessage = "Restart another round?"
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .cancel) { _ in
            self.restartAnotherRound()
        })

        self.present(alert, animated: true, completion: nil)
    }

    private func showAdditionalBallPopUp() {
        let alertTitle = "Good job!"
        let alertMessage = "You've earned an additional ball."
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func restartAnotherRound() {
        gameEngine.addDefaultPegs()
        addDefaultPegImages()
        updateBallsNumberLabel()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
