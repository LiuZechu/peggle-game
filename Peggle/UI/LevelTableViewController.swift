//
//  LevelTableViewController.swift
//  Peggle
//
//  Created by Liu Zechu on 31/1/20.
//  Copyright © 2020 Liu Zechu. All rights reserved.
//

import UIKit

class LevelTableViewController: UITableViewController {
    var logic: Logic!
    weak var delegate: LoadGameBoardDelegate?
    private var levelNames = [String]()
    private var levelNameSelected: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        levelNames = logic.fetchAllLevelNames()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "levelTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? LevelTableViewCell else {
            fatalError("The dequeued cell is not an instance of LevelTableViewCell.")
        }

        // Fetches the appropriate game board for the data source layout.
        let level = levelNames[indexPath.row]
        cell.levelLabel.text = level
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LevelTableViewCell else {
            return
        }
        
        levelNameSelected = cell.levelLabel.text ?? "[unnamed]"
        delegate?.loadGameBoard(name: levelNameSelected)
        self.performSegue(withIdentifier: "startGameWithLoadedLevel", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGameWithLoadedLevel" {
             if let gameViewController: GameViewController =
                 segue.destination as? GameViewController {
                gameViewController.delegate = self
             }
        }
    }
}

extension LevelTableViewController: GetGameBoardDelegate {
    func getGameBoard() -> GameBoard {
        return logic.fetchGameBoardByName(name: levelNameSelected) ??
            GameBoard(name: "default level")
    }
}
