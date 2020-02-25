//
//  StorageManger.swift
//  Peggle
//
//  Created by Liu Zechu on 30/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class StorageManager: Storage {

    var currentGameBoardStorageObject: NSManagedObject?

    /// Saves the current version of game board as a modification to an old game board.
    /// Returns true if save is successful.
    /// Returns false if name already exists or is empty.
    func saveOldGameBoard(model: Model) -> Bool {
        let gameBoard = model.getCurrentGameBoard()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if let currentGameBoardStorageObject = currentGameBoardStorageObject {
            let oldName = currentGameBoardStorageObject.value(forKeyPath: "name") as? String ?? ""
            let newName = gameBoard.name
            let isNewNameEmpty = newName.trimmingCharacters(in: .whitespaces).isEmpty
            let validName = !isNewNameEmpty && !checkNameAlreadyExists(name: newName, except: oldName)
            guard validName else {
                return false
            }
            
            managedContext.delete(currentGameBoardStorageObject)
        }
        
        save(gameBoard: gameBoard, managedContext: managedContext)
        
        return true
    }
    
    /// Saves the current version of game board as a new level.
    /// Returns true if save is successful.
    /// Returns false if name already exists or is empty.
    func saveNewGameBoard(model: Model) -> Bool {
        let gameBoard = model.getCurrentGameBoard()
        let isNameEmpty = gameBoard.name.trimmingCharacters(in: .whitespaces).isEmpty
        let validName = !isNameEmpty && !checkNameAlreadyExists(name: gameBoard.name)
        guard validName else {
            return false
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        save(gameBoard: gameBoard, managedContext: managedContext)
        
        return true
    }
    
    func fetchAllLevelNames() -> [String] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameBoard")
        
        var allGameBoards: [NSManagedObject] = []
        do {
            allGameBoards = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // gets all the names of the game boards as strings
        return allGameBoards.map {
            guard let levelName = $0.value(forKeyPath: "name") as? String else {
                return "[unnamed]"
            }
            return levelName
        }
    }
    
    func fetchGameBoardByName(name: String) -> GameBoard? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameBoard")
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        var gameBoards: [NSManagedObject] = []
        do {
            gameBoards = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        guard let gameBoardStorageObj = gameBoards.first else {
            return nil
        }
        
        // update current game board storage object
        currentGameBoardStorageObject = gameBoardStorageObj
        
        // creating game board object from data record
        let levelName = (gameBoardStorageObj.value(forKeyPath: "name") as? String)!
        let pegMOs = (gameBoardStorageObj.value(forKeyPath: "pegs") as? NSMutableSet)!
        var pegs = [Peg]()
        
        for pegMO in pegMOs {
            let pegColorBool = (pegMO as AnyObject).value(forKeyPath: "color") as? Int
            var pegColor: PegColor
            if pegColorBool == 1 {
                pegColor = PegColor.blue
            } else {
                pegColor = PegColor.orange
            }
            let xLocation = (pegMO as AnyObject).value(forKeyPath: "xPosition") as? Double ?? 0.0
            let yLocation = (pegMO as AnyObject).value(forKeyPath: "yPosition") as? Double ?? 0.0
            
            let peg = Peg(color: pegColor, location: CGPoint(x: xLocation, y: yLocation))
            pegs.append(peg)
        }
        
        let gameBoard = GameBoard(name: levelName, pegs: Set(pegs))
        return gameBoard
    }
        
    private func save(gameBoard: GameBoard, managedContext: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "GameBoard", in: managedContext)!
        let gameBoardMO = NSManagedObject(entity: entity, insertInto: managedContext)
        
        let levelName = gameBoard.name
        gameBoardMO.setValue(levelName, forKey: "name")

        // add pegs to the storage object
        var pegMOs = [NSManagedObject]()
        for peg in gameBoard.pegs {
            let entity = NSEntityDescription.entity(forEntityName: "Peg", in: managedContext)!
            let pegMO = NSManagedObject(entity: entity, insertInto: managedContext)
            let pegColorBoolean = peg.color == .blue
            let pegXPosition = Double(peg.location.x)
            let pegYPosition = Double(peg.location.y)
            
            pegMO.setValue(pegColorBoolean, forKeyPath: "color")
            pegMO.setValue(pegXPosition, forKeyPath: "xPosition")
            pegMO.setValue(pegYPosition, forKeyPath: "yPosition")

            pegMOs.append(pegMO)
        }
        
        let pegStorageSet = gameBoardMO.mutableSetValue(forKey: "pegs")
        pegStorageSet.removeAllObjects() // clear all previously stored objects
        pegStorageSet.addObjects(from: pegMOs)

        // add pegs set to the game board storage object
        gameBoardMO.setValue(pegStorageSet, forKeyPath: "pegs")
        
        currentGameBoardStorageObject = gameBoardMO
        
        // commit changes and save to disk
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func isFirstGameBoard() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameBoard")
        var gameBoards: [NSManagedObject] = []
        do {
            gameBoards = try managedContext.fetch(fetchRequest)
        } catch {
            return true
        }
        
        return gameBoards.isEmpty
    }
    
    private func checkNameAlreadyExists(name: String, except: String = "") -> Bool {
        return !fetchAllLevelNames().filter {
            let identicalName = $0.trimmingCharacters(in: .whitespacesAndNewlines) ==
                name.trimmingCharacters(in: .whitespacesAndNewlines)
            let excludesException = $0.trimmingCharacters(in: .whitespacesAndNewlines) ==
                except.trimmingCharacters(in: .whitespacesAndNewlines)
            return identicalName && !excludesException
        }.isEmpty
    }
    
}
