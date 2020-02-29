//
//  SampleLevelsLoader.swift
//  Peggle
//
//  Created by Liu Zechu on 29/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGFloat

/// This class contains several preloaded levels of Peggle.
class SampleLevelsLoader {
    var games: [GameBoard]
    var multiplier: Double
    
    init(multiplier: Double) {
        games = []
        self.multiplier = multiplier
        
        let firstLevel = getFirstLevel()
        let secondLevel = getSecondLevel()
        let thirdLevel = getThirdLevel()
        let adjustedFirstLevel = adjustGameBoardByMultiplier(gameboard: firstLevel, multiplier: multiplier)
        let adjustedSecondLevel = adjustGameBoardByMultiplier(gameboard: secondLevel, multiplier: multiplier)
        let adjustedThirdLevel = adjustGameBoardByMultiplier(gameboard: thirdLevel, multiplier: multiplier)
        games.append(adjustedFirstLevel)
        games.append(adjustedSecondLevel)
        games.append(adjustedThirdLevel)
    }
    
    func adjustGameBoardByMultiplier(gameboard: GameBoard, multiplier: Double) -> GameBoard {
        var adjustedPegs = Set<Peg>()
        for peg in gameboard.pegs {
            let oldLocation = peg.location
            let newX = oldLocation.x * CGFloat(multiplier)
            let newY = oldLocation.y * CGFloat(multiplier)
            let newLocation = CGPoint(x: newX, y: newY)
            let newRadius = peg.radius * CGFloat(multiplier)
            
            let newPeg = Peg(color: peg.color, location: newLocation, shape: peg.shape,
                             radius: newRadius)
            adjustedPegs.insert(newPeg)
        }
        
        return GameBoard(name: gameboard.name, pegs: adjustedPegs)
    }
    
    func getFirstLevel() -> GameBoard {
        let peg01 = Peg(color: .blue, location: CGPoint(x: 458, y: 490), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg02 = Peg(color: .blue, location: CGPoint(x: 142, y: 351), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg03 = Peg(color: .orange, location: CGPoint(x: 188, y: 420), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg04 = Peg(color: .blue, location: CGPoint(x: 110, y: 268), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg05 = Peg(color: .blue, location: CGPoint(x: 310, y: 494), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg06 = Peg(color: .green, location: CGPoint(x: 502, y: 442), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg07 = Peg(color: .green, location: CGPoint(x: 106, y: 560), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg08 = Peg(color: .green, location: CGPoint(x: 550, y: 609), shape: .equilateralTriangle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg09 = Peg(color: .green, location: CGPoint(x: 383, y: 510), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg10 = Peg(color: .green, location: CGPoint(x: 661, y: 548), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg11 = Peg(color: .blue, location: CGPoint(x: 597, y: 326), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg12 = Peg(color: .blue, location: CGPoint(x: 632, y: 246), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg13 = Peg(color: .blue, location: CGPoint(x: 230, y: 609), shape: .equilateralTriangle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg14 = Peg(color: .green, location: CGPoint(x: 254, y: 458), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg15 = Peg(color: .orange, location: CGPoint(x: 554, y: 390), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg16 = Peg(color: .orange, location: CGPoint(x: 381, y: 673), shape: .equilateralTriangle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let pegs = [peg01, peg02, peg03, peg04, peg05, peg06, peg07, peg08, peg09, peg10,
                    peg11, peg12, peg13, peg14, peg15, peg16]
        
        return GameBoard(name: "First Level", pegs: Set<Peg>(pegs))
    }
    
    func getSecondLevel() -> GameBoard {
        let peg01 = Peg(color: .blue, location: CGPoint(x: 657, y: 225), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg02 = Peg(color: .blue, location: CGPoint(x: 664.5, y: 790), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg03 = Peg(color: .orange, location: CGPoint(x: 298, y: 506), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg04 = Peg(color: .green, location: CGPoint(x: 373, y: 508), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg05 = Peg(color: .blue, location: CGPoint(x: 372, y: 576), shape: .equilateralTriangle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg06 = Peg(color: .green, location: CGPoint(x: 436, y: 510), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg07 = Peg(color: .blue, location: CGPoint(x: 108, y: 783), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg08 = Peg(color: .blue, location: CGPoint(x: 372, y: 432), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let peg09 = Peg(color: .blue, location: CGPoint(x: 127, y: 228), shape: .circle,
                        powerup: nil, radius: 20, angleOfRotation: 0)
        let pegs = [peg01, peg02, peg03, peg04, peg05, peg06, peg07, peg08, peg09]
        
        return GameBoard(name: "Second Level", pegs: Set<Peg>(pegs))
    }
    
    func getThirdLevel() -> GameBoard {
        var pegs = Set<Peg>()
        for row in 4...9 {
            for column in 2...8 {
                let xCoordinate = CGFloat(column * 70)
                let yCoordinate = CGFloat(row * 70)
                let location = CGPoint(x: xCoordinate, y: yCoordinate)
                let pegColor = (row + column) % 3 == 0 ? PegColor.blue
                    : (row + column) % 3 == 1 ? PegColor.orange : PegColor.green
                let peg = Peg(color: pegColor, location: location, shape: .circle)
                
                pegs.insert(peg)
            }
        }
        
        return GameBoard(name: "Third Level", pegs: pegs)
    }
}
