//
//  MenuScreenViewController.swift
//  Peggle
//
//  Created by Liu Zechu on 25/2/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class MenuScreenViewController: UIViewController {
    private var logic: Logic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let model = ModelManager()
        let storage = StorageManager()
        logic = LogicManager(model: model, storage: storage)
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
