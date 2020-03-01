//
//  ViewController.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 8/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, Renderer {
    weak var delegate: GetGameBoardDelegate?
    var gameEngine: PeggleGameEngine!
    
    private var isLaunchable: Bool = true // indicates whether the cannon ball is ready to be launched now
        
    @IBOutlet private var background: UIImageView!
    @IBOutlet private var ballsNumberLabel: UILabel!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var cannonImageView: UIImageView!
    private var ballImageView: UIImageView!
    private var bucketImageView: UIImageView!
    private var pegImages: [UIImageView] = []
    private var glowPegImages: [UIImageView] = []
    private var chaosModePegImages: [Peg: UIImageView] = [:] // for special mode

    override func viewDidLoad() {
        super.viewDidLoad()

        let gameboard = delegate?.getGameBoard() ?? GameBoard(name: "default gameboard")
        gameEngine = PeggleGameEngine(leftBoundary: Double(self.view.frame.minX),
                                      rightBoundary: Double(self.view.frame.maxX),
                                      upperBoundary: Double(self.view.frame.minY),
                                      lowerBoundary: Double(self.view.frame.maxY),
                                      gameboard: gameboard)
        gameEngine.addRenderer(renderer: self)
        addInitialPegImages()
        gameEngine.setBallYPosition(yPosition: Double(cannonImageView.center.y))
        addBallToScreen()
        addBucketToScreen()
        updateScoreLabels()
        playBackgroundMusic()
        
        // make cannon on top of ball
        self.view.bringSubviewToFront(cannonImageView)
        
        // rotation of cannon
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePegDrag))
        self.view.addGestureRecognizer(dragRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showInitialPopUp()
    }
    
    private func playBackgroundMusic() {
        if let player = AudioManager.sharedManager.backgroundPlayer {
            player.prepareToPlay()
            player.numberOfLoops = -1
            player.play()
        }
    }
    
    private func stopBackgroundMusic() {
        if let player = AudioManager.sharedManager.backgroundPlayer {
            player.stop()
        }
    }
    
    private func addBallToScreen() {
        let ballImage = UIImage(named: "ball")
        let location = gameEngine.getBallLocation()
        let frame = CGRect(x: location.x - CGFloat(CannonBall.radius),
                           y: location.y - CGFloat(CannonBall.radius),
                           width: CGFloat(CannonBall.radius) * 2,
                           height: CGFloat(CannonBall.radius) * 2)
        let ballViewToAdd = UIImageView(frame: frame)
        ballViewToAdd.layer.cornerRadius = Peg.defaultRadius
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
        var touchLocation = recognizer.location(in: nil)
        if recognizer.state == .began {
            touchLocation = recognizer.location(in: nil)
            let angleOfRotation = calculateAngleOfRotation(cannonLocation: cannonLocation,
                                                           touchLocation: touchLocation)
            cannonImageView.transform = CGAffineTransform(rotationAngle: angleOfRotation)
        } else if recognizer.state == .ended {
            let xDifference = touchLocation.x - cannonLocation.x
            let yDifference = touchLocation.y - cannonLocation.y
            
            var launchAngle = Double(atan(yDifference / xDifference))
            // prevent launching upwards
            if yDifference < 0 {
                if xDifference > 0 {
                    launchAngle = -Double.pi
                } else {
                    launchAngle = Double.pi
                }
            }
            
            // launch the ball
            gameEngine.launchCannonBall(angle: launchAngle, initialSpeed: PeggleGameEngine.initialBallSpeed)
            isLaunchable = false
            gameEngine.isRestarted = false
        }

        let angleOfRotation = calculateAngleOfRotation(cannonLocation: cannonLocation, touchLocation: touchLocation)
        cannonImageView.transform = CGAffineTransform(rotationAngle: angleOfRotation)
    }
    
    private func calculateAngleOfRotation(cannonLocation: CGPoint,
                                          touchLocation: CGPoint) -> CGFloat {
        let xDifference = touchLocation.x - cannonLocation.x
        let yDifference = touchLocation.y - cannonLocation.y
        
        // prevent launching above the cannon
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
        
    private func addBucketToScreen() {
        let bucketImage = UIImage(named: "bucket")
        let location = gameEngine.getBucketBottomCenterLocation()
        let frame = CGRect(x: location.x - CGFloat(150 / 2), y: location.y - CGFloat(150),
                           width: 150, height: 150)
        let bucketViewToAdd = UIImageView(frame: frame)
        bucketViewToAdd.contentMode = .scaleAspectFit
        bucketViewToAdd.image = bucketImage
        self.view.addSubview(bucketViewToAdd)
        
        bucketImageView = bucketViewToAdd
    }
    
    private func addInitialPegImages() {
        let pegs = gameEngine.getAllPegs()
        for peg in pegs {
            let pegImage =
                ViewControllerUtility.createPegImageView(at: peg.location, color: peg.color, shape: peg.shape,
                                                         isGlow: false, radius: peg.radius,
                                                         angle: peg.angleOfRotation)
            self.view.addSubview(pegImage)
            pegImages.append(pegImage)
        }
    }
    
    private func deleteAllGlowingPegs() {
        for image in glowPegImages {
            UIView.animate(withDuration: 2, animations: {
                image.alpha = 0
            }, completion: { _ in
                self.removePegAndItsView(from: image)
            })
        }
        
        glowPegImages = []
        gameEngine.shouldDeleteAllPegs = false
        
        // after all the deletions, restart the round
        Timer.scheduledTimer(timeInterval: TimeInterval(2.2), target: self,
                             selector: #selector(restart), userInfo: nil, repeats: false)
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
        
        // update the ball number and score
        updateScoreLabels()
        
        // If the player has won/lost, restart another round
        if gameEngine.hasWon() || gameEngine.hasLost() {
            showFinalPopUp()
            playCheerSoundEffect() // Note: cheering is played even if the player loses to cheer them up
        }
    }
    
    func render() {
        // move ball
        ballImageView.center = gameEngine.getBallLocation()
        
        // move bucket
        let newBucketLocationX = gameEngine.getBucketBottomCenterLocation().x
        let newBucketLocationY = gameEngine.getBucketBottomCenterLocation().y - 150 / 2
        bucketImageView.center = CGPoint(x: newBucketLocationX, y: newBucketLocationY)
        
        lightUpPegsHit()
        
        // play sound effect
        if gameEngine.isBallHit() {
            playBounceSoundEffect()
        }

        if gameEngine.shouldDeleteAllPegs {
            deleteAllGlowingPegs()
        }
        
        // show additional ball popup
        if gameEngine.isBallInsideBucket() {
            showAdditionalBallPopUp()
        }
        
        // special mode
        handleChaosMode()
    }
    
    private func lightUpPegsHit() {
        for peg in gameEngine.getPegsHit() where peg.hasBeenHit == false {
            for image in pegImages where image.containsLocation(location: peg.location, circleRadius: peg.radius) {
                let center = image.center
                image.removeFromSuperview()
                let glowImage =
                    ViewControllerUtility.createPegImageView(at: center, color: peg.color, shape: peg.shape,
                                                             isGlow: true, radius: peg.radius,
                                                             angle: peg.angleOfRotation)
                self.view.addSubview(glowImage)
                glowPegImages.append(glowImage)
                // for special mode
                chaosModePegImages[peg] = glowImage
            }
            peg.hasBeenHit = true
        }
    }
    
    private func playBounceSoundEffect() {
        if let player = AudioManager.sharedManager.bounceSoundPlayer {
            player.play()
        }
    }
    
    private func playCheerSoundEffect() {
        if let player = AudioManager.sharedManager.cheerSoundPlayer {
            player.play()
        }
    }
    
    // update the text on top right hand corner of the background
    private func updateScoreLabels() {
        ballsNumberLabel.text = "Balls left: \(gameEngine.numberOfBallsLeft)"
        scoreLabel.text = "Score: \(gameEngine.score)"
    }

    private func handleChaosMode() {
        guard gameEngine.isChaosMode else {
            return
        }
        for peg in gameEngine.getPegsHit() where peg.color != .red && peg.shape == .circle {
            peg.color = .red
            peg.hasBeenHit = false
            gameEngine.addToChaosPegs(peg: peg)
            let glowImage = chaosModePegImages[peg]
            glowPegImages = glowPegImages.filter { $0 != glowImage }
            glowImage?.removeFromSuperview()
        }
        lightUpPegsHit()
        for peg in gameEngine.getChaosPegs() {
            let glowImage = chaosModePegImages[peg]
            glowPegImages = glowPegImages.filter { $0 != glowImage }
            glowImage?.removeFromSuperview()
            let pegImage = ViewControllerUtility
                .createPegImageView(at: peg.location, color: peg.color, shape: peg.shape,
                                    isGlow: peg.isHit, radius: peg.radius, angle: peg.angleOfRotation)
            self.view.addSubview(pegImage)
            glowPegImages.append(pegImage)
            chaosModePegImages[peg] = pegImage
        }
    }
    
    @objc func returnToMainMenu() {
        gameEngine.stopGameLoop()
        stopBackgroundMusic()
        performSegue(withIdentifier: "backToMainFromGame", sender: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
