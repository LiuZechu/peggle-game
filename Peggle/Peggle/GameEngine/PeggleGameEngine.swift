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
    
    // To determine win/lose conditions
    static let totalNumberOfBalls = 10
    private(set) var numberOfBallsLeft = 10 // decrements every round
    var numberOfOrangePegsLeft: Int {
        return gameboard.getNumberOfPegsOfColor(color: .orange)
    }
    private var score: Int = 0
    
    private var hasBallEntered: Bool = false
    private var isGameLoopStopped: Bool = true
    private var typeOfPowerupChosen: Powerup!
    var isSpookyBallTriggered: Bool = false
    var isRestarted = false // indicates whether the previous game loop has ended and a new ball replenished
    var shouldDeleteAllPegs = false
    var isWindyMode = false // special mode
    var isChaosMode = false // special mode
    private var chaosPegs: [Peg] = []
    
    init(leftBoundary: Double, rightBoundary: Double,
         upperBoundary: Double, lowerBoundary: Double,
         gameboard: GameBoard) {
        physicsEngine = PhysicsEngine(leftBoundary: leftBoundary,
                                      rightBoundary: rightBoundary,
                                      upperBoundary: upperBoundary,
                                      lowerBoundary: lowerBoundary)
        self.gameboard = gameboard
        cannonBallInitialXPosition = (rightBoundary - leftBoundary) / 2
        cannonBall = CannonBall(xPosition: cannonBallInitialXPosition)
       
        bucket = Bucket(upperBoundary: lowerBoundary - 50, width: 150,
                        bottomCenterLocation: CGPoint(x: rightBoundary / 2,
                                                      y: lowerBoundary + 100))
        
        self.leftBoundary = leftBoundary
        self.rightBoundary = rightBoundary
        self.upperBoundary = upperBoundary
        self.lowerBoundary = lowerBoundary
        
        // set up the physics engine simulation
        addPhysicsBodiesForPegs()
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
    
    func stopGameLoop() {
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
    }
    
    func addRenderer(renderer: Renderer) {
        self.renderer = renderer
    }
    
    @objc func update(updater: CADisplayLink) {
        // special mode
        handleChaosMode()
        
        physicsEngine.update()
        renderer.render()
        
        checkBallOutOfBounds()
        moveBucket()
        checkWhetherBallInBucket()
        handleStuckBall()
        triggerPowerups()
    }
    
    private func checkBallOutOfBounds() {
        // if the ball is out of bounds, remove it
        if physicsEngine.isBodyOutOfLowerBound(body: cannonBall.physicsBody) {
            if isSpookyBallTriggered {
                teleportBallToCeiling()
            } else {
                _ = physicsEngine.removePhysicsBody(cannonBall.physicsBody)
            }
        }
    
        // delete pegs when ball flies out
        let chaosModeDeleteCondition = isChaosMode && isBallOutOfBounds() && chaosPegs.isEmpty && !isRestarted
        let normalDeleteCondition = !isChaosMode && isBallOutOfBounds() && !isRestarted && !isSpookyBallTriggered
        if normalDeleteCondition || chaosModeDeleteCondition {
            shouldDeleteAllPegs = true
            isRestarted = true
        }
    }
    
    private func moveBucket() {
        if bucket.hitsLeftBoundary(leftBoundary: leftBoundary)
            || bucket.hitsRightBoundary(rightBoundary: rightBoundary) {
            bucket.toggleDirection()
        }
        bucket.move()
    }
    
    private func checkWhetherBallInBucket() {
        if isBallInsideBucket() {
            // so that the count is not incremented repeatedly
            if hasBallEntered == false {
                incrementBallCount()
            }
            hasBallEntered = true
        }
    }
    
    private func handleStuckBall() {
        // increase ball hit count to detect whether it's stuck
        if cannonBall.isHit {
            cannonBall.hitCounter += 1
            cannonBall.isHit = false
        }
        // ball and pegs should be deleted if the ball gets stuck
        if isBallStuck() && !isRestarted {
            shouldDeleteAllPegs = true
            isRestarted = true
        }
    }
    
    private func triggerPowerups() {
        for peg in getAllPegs() where peg.isPowerupActivated() {
            if peg.powerup == Powerup.spaceBlast {
                triggerSpaceBlast(centerPeg: peg)
            } else if peg.powerup == Powerup.spookyBall {
                triggerSpookyBall()
            }
        }
    }
    
    private func handleChaosMode() {
        guard isChaosMode else {
            return
        }
        for peg in chaosPegs {
            let body = peg.physicsBody
            if !body.isMovable {
                _ = physicsEngine.removePhysicsBody(body)
                body.isMovable = true
                _ = physicsEngine.addPhysicsBody(body)
                let randomLaunchAngle = Double.random(in: 0 ..< (2 * Double.pi))
                let randomLaunchSpeed = Double.random(in: 0 ..< 600)
                body.launch(angle: randomLaunchAngle, speed: randomLaunchSpeed)
            }
            if physicsEngine.isBodyOutOfLowerBound(body: body) {
                _ = physicsEngine.removePhysicsBody(body)
                chaosPegs = chaosPegs.filter { $0 != peg }
            }
        }
    }
    
    func addWindToBall() {
        let windMagnitude = Double.random(in: -600 ... 600)
        let windForce = Vector(xComponent: windMagnitude, yComponent: 0)
        cannonBall.physicsBody.applyForce(windForce)
    }
    
    func addToChaosPegs(peg: Peg) {
        guard !chaosPegs.contains(peg) else {
            return
        }
        chaosPegs.append(peg)
    }
    
    func getChaosPegs() -> [Peg] {
        return chaosPegs
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
        if isWindyMode {
            addWindToBall()
        }
    }
        
    private func addPhysicsBodiesForPegs() {
        for peg in gameboard.pegs {
            _ = physicsEngine.addPhysicsBody(peg.physicsBody)
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
    
    func triggerSpaceBlast(centerPeg: Peg) {
        let affectedPegs = getAllPegs().filter {
            $0.getDistanceFrom(otherPeg: centerPeg) <= PeggleGameEngine.spaceBlastRadius
        }
        
        for peg in affectedPegs {
            peg.isHit = true
        }
    }
    
    func triggerSpookyBall() {
        isSpookyBallTriggered = true
    }
    
    func setPowerUp(powerup: Powerup) {
        typeOfPowerupChosen = powerup
        
        // go through all the green pegs in game engine and
        // make sure they are set to the correct powerup
        for peg in gameboard.pegs where peg.color == .green {
            peg.powerup = powerup
        }
    }
    
    func isBallStuck() -> Bool {
        return cannonBall.hitCounter > gameboard.pegs.count * 10
    }
    
    func isBallHit() -> Bool {
        return cannonBall.isHit
    }
    
    func teleportBallToCeiling() {
        let originalX = cannonBall.location.x
        let newX = originalX
        let newY = 0 - Peg.defaultRadius
        let newLocation = CGPoint(x: newX, y: newY)
        
        cannonBall.location = newLocation
        isSpookyBallTriggered = false
    }
    
    func getCurrentScore() -> Int {
        score += cannonBall.hitCounter * gameboard.pegs.count
        return score
    }
    
    private func findPegFromLocation(at point: CGPoint) -> Peg? {
        let pegSet = gameboard.pegs.filter {
            let isXWithinRange = abs($0.location.x - point.x) < Peg.defaultRadius
            let isYWithinRange = abs($0.location.y - point.y) < Peg.defaultRadius
            return isXWithinRange && isYWithinRange
        }
        
        return pegSet.first
    }
}
