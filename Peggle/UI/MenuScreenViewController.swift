//
//  MenuScreenViewController.swift
//  Peggle
//
//  Created by Liu Zechu on 25/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class MenuScreenViewController: UIViewController {
    static let fixedWidth: CGFloat = 768
    static let fixedHeight: CGFloat = 1_024

    private var logic: LevelDesignerLogic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftBoundary = self.view.frame.minX
        let rightBoundary = self.view.frame.maxX
        let upperBoundary = self.view.frame.minY
        let lowerBoundary = self.view.frame.maxY
        let screenHeight = lowerBoundary - upperBoundary
        let screenWidth = rightBoundary - leftBoundary
        let displayMultiplier = min(screenHeight / MenuScreenViewController.fixedHeight,
                                    screenWidth / MenuScreenViewController.fixedWidth)
        let storage = StorageManager()
        storage.savePreloadedLevels(multiplier: Double(displayMultiplier))
        let model = ModelManager()
        logic = LevelDesignerLogicManager(model: model, storage: storage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectLevel" {
            if let levelTableViewController: LevelTableViewController =
                segue.destination as? LevelTableViewController {
                levelTableViewController.logic = logic
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
