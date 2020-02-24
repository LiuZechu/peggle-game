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
    static let initialBallSpeed: Double = 200

    private let physicsEngine: PhysicsEngine
    private let gameboard: GameBoard
    private var cannonBall: CannonBall
    private let cannonBallInitialXPosition: Double!
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
    
    private var isGameLoopStopped: Bool = true

    init(leftBoundary: Double, rightBoundary: Double, upperBoundary: Double, lowerBoudary: Double) {
        physicsEngine = PhysicsEngine(leftBoundary: leftBoundary,
                                      rightBoundary: rightBoundary,
                                      upperBoundary: upperBoundary,
                                      lowerBoundary: lowerBoudary)
        gameboard = GameBoard(name: "default level")
        cannonBallInitialXPosition = (rightBoundary - leftBoundary) / 2
        cannonBall = CannonBall(xPosition: cannonBallInitialXPosition)
        
        addDefaultPegs()
        _ = physicsEngine.addPhysicsBody(cannonBall.physicsBody)
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
        _ = physicsEngine.addPhysicsBody(cannonBall.physicsBody)
        
        // when a ball is replenished, decrement the number of balls left
        numberOfBallsLeft -= 1
    }
    
    func addRenderer(renderer: Renderer) {
        self.renderer = renderer
    }
    
    @objc func update(updater: CADisplayLink) {
        physicsEngine.update()
        renderer.render()
    }
    
    func getAllPegs() -> Set<Peg> {
        return gameboard.pegs
    }
    
    func getBallLocation() -> CGPoint {
        return cannonBall.location
    }
    
    func isBallOutOfBounds() -> Bool {
        return physicsEngine.bodyOutOfLowerBound(body: cannonBall.physicsBody)
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
        for row in 1...4 {
            for col in 1...3 {
                let xCoord = col * 200
                let yCoord = row * 200
                let location = CGPoint(x: xCoord, y: yCoord)
                let color = (row + col) % 2 == 0 ? PegColor.blue : PegColor.orange
                let pegToAdd = Peg(color: color, location: location)
                
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
    
    private func findPegFromLocation(at point: CGPoint) -> Peg? {
        let pegSet = gameboard.pegs.filter {
            let isXWithinRange = abs($0.location.x - point.x) < Peg.radius
            let isYWithinRange = abs($0.location.y - point.y) < Peg.radius
            return isXWithinRange && isYWithinRange
        }
        
        return pegSet.first
    }
}
