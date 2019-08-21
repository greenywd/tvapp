//
//  ShowSeasonsTableViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 31/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowSeasonsTableViewController: UITableViewController {
    
    var showID: Int32!
    var episodes: [Episode]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    var seasons: [Int32]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let episodes = PersistenceService.getEpisodes(show: showID) {
            self.episodes = episodes
            self.seasons = Set(episodes.map { $0.airedSeason ?? 999 }).sorted()
        } else {
            TVDBAPI.getEpisodes(show: showID) { (episodeList) in
                if let episodes = episodeList {
                    if !episodes.isEmpty {
                        self.episodes = episodes
                        // Get number of episodes in season
                        // let seasons = self.episodes!.filter{$0.airedSeason! == 5}.count
                        self.seasons = Set((episodeList ?? []).compactMap { $0.airedSeason }).sorted()
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        let alert = UIAlertController(title: "Error", message: "No episodes available", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = seasons {
            return seasons!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seasonCell", for: indexPath)
        
        if let _ = seasons {
            cell.textLabel?.text = "Season \(seasons![indexPath.row])"
            cell.detailTextLabel?.text = "\(self.episodes!.filter{$0.airedSeason! == indexPath.row}.count) Episodes"
        }
        
        // Configure the cell...
        print("configured cell")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        guard let selectedTableViewCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a ShowTableViewCell") }
        
        guard let episodeVC = segue.destination as? ShowEpisodeViewController
            else { preconditionFailure("Expected a ShowViewController") }
        
        if (segue.identifier == "seasonToShow") {
            episodeVC.episodes = self.episodes!.filter{$0.airedSeason! == indexPath.row}
        }
    }
    
    
}
