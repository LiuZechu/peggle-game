//
//  PeggleGameEngine.swift
//  PegglePhysics
//
//  Created by Liu Zechu on 8/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import UIKit

class PeggleGameEngine {
    static let initialBallSpeed: Double = 300
    static let spaceBlastRadius: Double = 100

    private let physicsEngine: PhysicsEngine
    private let gameboard: GameBoard
    private var cannonBall: CannonBall
    private let cannonBallInitialXPosition: Double!
    private var cannonBallInitialYPosition: Double!
    private let bucket: Bucket
    
    private let leftBoundary: Double
    private let rightBoundary: Double
    private let upperBoundary: Double
    private let lowerBoundary: Double
    
    private var displayLink: CADisplayLink!
    private var renderer: Renderer!
    
    // player's stats to determing winningl/losing
    // winning condition:
    // To win, clear all orange pegs.
    // You start with 10 balls. Every time you shoot a ball, the number of balls get subtracted.
    // You lose if you run out of balls and there are still orange pegs remaining in the game.
    static let totalNumberOfBalls = 10
    private(set) var numberOfBallsLeft = 10 // decrements every round
    var numberOfOrangePegsLeft: Int {
        return gameboard.getNumberOfPegsOfColor(color: .orange)
    }
    
    private var hasBallEntered: Bool = false
    private var isGameLoopStopped: Bool = true
    var isSpookyBallTriggered: Bool = false

    init(leftBoundary: Double, rightBoundary: Double, upperBoundary: Double, lowerBoundary: Double) {
        physicsEngine = PhysicsEngine(leftBoundary: leftBoundary,
                                      rightBoundary: rightBoundary,
                                      upperBoundary: upperBoundary,
                                      lowerBoundary: lowerBoundary)
        gameboard = GameBoard(name: "default level")
        cannonBallInitialXPosition = (rightBoundary - leftBoundary) / 2
        cannonBall = CannonBall(xPosition: cannonBallInitialXPosition)
       
        // ARBITRARY FOR NOW
        bucket = Bucket(upperBoundary: lowerBoundary - 150, width: 150,
                        bottomCenterLocation: CGPoint(x: rightBoundary / 2,
                                                      y: lowerBoundary))
        
        self.leftBoundary = leftBoundary
        self.rightBoundary = rightBoundary
        self.upperBoundary = upperBoundary
        self.lowerBoundary = lowerBoundary
        
        addDefaultPegs()
        _ = physicsEngine.addPhysicsBody(cannonBall.physicsBody)
    }
    
    func setBallYPosition(yPosition: Double) {
        cannonBall.setYLocation(yPosition: yPosition)
        cannonBallInitialYPosition = yPosition
    }
    
    private func startGameLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
        displayLink.preferredFramesPerSecond = PhysicsEngine.framerate
        
        isGameLoopStopped = false
    }
    
    private func stopGameLoop() {
        guard !isGameLoopStopped else {
            return
        }
        
        displayLink.invalidate()
        displayLink = nil
        isGameLoopStopped = true
    }
    
    // called after the ball is out of bounds, so that a new ball can be replenished
    func restartAnotherRound() {
        stopGameLoop()
        _ = physicsEngine.removePhysicsBody(cannonBall.physicsBody)
        cannonBall = CannonBall(xPosition: cannonBallInitialXPosition)
        cannonBall.physicsBody.position.yComponent = cannonBallInitialYPosition
        _ = physicsEngine.addPhysicsBody(cannonBall.physicsBody)
        
        // when a ball is replenished, decrement the number of balls left
        numberOfBallsLeft -= 1
        
        hasBallEntered = false
        
        // when there's no more balls, increase back to 10
        if hasWon() || hasLost() {
            numberOfBallsLeft = PeggleGameEngine.totalNumberOfBalls
        }
    }
    
    func addRenderer(renderer: Renderer) {
        self.renderer = renderer
    }
    
    @objc func update(updater: CADisplayLink) {
        physicsEngine.update()
        renderer.render()
        
        // if the ball is out of bounds, remove it
        if physicsEngine.isBodyOutOfLowerBound(body: cannonBall.physicsBody) {
            if isSpookyBallTriggered {
                teleportBallToCeiling()
            } else {
                _ = physicsEngine.removePhysicsBody(cannonBall.physicsBody)
            }
        }
        
        // move the bucket
        if bucket.hitsLeftBoundary(leftBoundary: leftBoundary)
            || bucket.hitsRightBoundary(rightBoundary: rightBoundary) {
            bucket.toggleDirection()
        }
        bucket.move()
        
        // check whether the cannon ball is in the bucket
        if isBallInsideBucket() {
            print("the ball is inside the bucket!")
            // so that the count is not incremented repeatedly
            if hasBallEntered == false {
                incrementBallCount()
            }
            hasBallEntered = true
        }
        
        // trigger powerups
        for peg in getAllPegs() where peg.isPowerupActivated() {
            if peg.powerup == Powerup.spaceBlast {
                triggerSpaceBlast(centerPeg: peg)
            } else if peg.powerup == Powerup.spookyBall {
                triggerSpookyBall()
            }
        }
    }
    
    // called when the ball enters the bucket
    private func incrementBallCount() {
        numberOfBallsLeft += 1
    }
    
    func getAllPegs() -> Set<Peg> {
        return gameboard.pegs
    }
    
    func getBallLocation() -> CGPoint {
        return cannonBall.location
    }
    
    func getBucketBottomCenterLocation() -> CGPoint {
        return bucket.bottomCenterLocation
    }
    
    func isBallOutOfBounds() -> Bool {
        return physicsEngine.isBodyOutOfLowerBound(body: cannonBall.physicsBody)
    }
    
    func isBallInsideBucket() -> Bool {
        return bucket.isInBucket(ballLocation: cannonBall.location, ballRadius: CannonBall.radius)
    }
    
    func getPegsHit() -> Set<Peg> {
        var hitPegs = Set<Peg>()
        for peg in gameboard.pegs where peg.physicsBody.isHit {
            peg.isHit = true
            hitPegs.insert(peg)
        }

        return hitPegs
    }
    
    func launchCannonBall(angle: Double, initialSpeed: Double) {
        startGameLoop()
        cannonBall.physicsBody.launch(angle: angle, speed: initialSpeed)
    }
    
    // add default pegs to game board and physics engine
    func addDefaultPegs() {
        for row in 2...6 {
            for col in 1...5 {
                let xCoord = col * 100
                let yCoord = row * 100
                let location = CGPoint(x: xCoord, y: yCoord)
                //let color = (row + col) % 2 == 0 ? PegColor.blue : PegColor.orange
                let color = (row + col) % 3 == 0 ?
                    PegColor.blue : (row + col) % 3 == 1 ? PegColor.orange : PegColor.green
                
                let pegToAdd = Peg(color: color, location: location)
                // TEMPORARY
                if color == .green {
                    pegToAdd.powerup = .spookyBall
                }
                
                _ = gameboard.addPeg(toAdd: pegToAdd)
                _ = physicsEngine.addPhysicsBody(pegToAdd.physicsBody)
            }
        }
    }
    
    func removePegFromCurrentGameBoard(at location: CGPoint) -> Bool {
        if let peg = findPegFromLocation(at: location) {
            // remove the physics body associated with this peg
            let physicsBodyRemovedSuccessfully = physicsEngine.removePhysicsBody(peg.physicsBody)
            let pegRemovedSuccessfully = gameboard.removePeg(toRemove: peg)
            return physicsBodyRemovedSuccessfully && pegRemovedSuccessfully
        } else {
            return false
        }
    }
    
    func hasWon() -> Bool {
        return numberOfOrangePegsLeft == 0
    }
    
    func hasLost() -> Bool {
        return numberOfOrangePegsLeft != 0 && numberOfBallsLeft <= 0
    }
    
    // POWERUPS
    func triggerSpaceBlast(centerPeg: Peg) {
        let affectedPegs = getAllPegs().filter {
            $0.getDistanceFrom(otherPeg: centerPeg) <= PeggleGameEngine.spaceBlastRadius
        }
        
        for peg in affectedPegs {
            print("here")
            peg.isHit = true
        }
    }
    
    func triggerSpookyBall() {
        isSpookyBallTriggered = true
    }
    
    func teleportBallToCeiling() {
//        let verticalDistance = lowerBoundary - upperBoundary
//        let originalY = cannonBall.location.y
        let originalX = cannonBall.location.x
//        let newY = originalY - CGFloat(verticalDistance)
        let newX = originalX
        let newY = 0 - Peg.radius
        let newLocation = CGPoint(x: newX, y: newY)
        
        cannonBall.location = newLocation
        isSpookyBallTriggered = false
    }
    
    private func findPegFromLocation(at point: CGPoint) -> Peg? {
        let pegSet = gameboard.pegs.filter {
            let isXWithinRange = abs($0.location.x - point.x) < Peg.radius
            let isYWithinRange = abs($0.location.y - point.y) < Peg.radius
            return isXWithinRange && isYWithinRange
        }
        
        return pegSet.first
    }
}
