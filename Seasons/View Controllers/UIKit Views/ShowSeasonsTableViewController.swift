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
        
        // Check to see if we've got the show favourited and load the episodes from CoreData if we do.
        // If not, download them
        if let episodes = PersistenceService.getEpisodes(show: showID) {
            self.episodes = episodes
            self.seasons = Set(episodes.map { $0.airedSeason ?? 999 }).sorted()
            
            let markWatchedButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext"), style: .plain, target: self, action: #selector(markEpisodes))
            navigationItem.rightBarButtonItem = markWatchedButtonItem
            
        } else {
            TVDBAPI.getEpisodes(show: showID) { (episodeList) in
                if let episodes = episodeList {
                    if !episodes.isEmpty {
                        self.episodes = episodes
                        
                        // Get number of episodes in season
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
    
    @objc func markEpisodes() {
        let alertSheet = UIAlertController(title: "Mark All Seasons as:", message: nil, preferredStyle: .actionSheet)
        alertSheet.addAction(UIAlertAction(title: "Watched", style: .default, handler: { (alertAction) in
            PersistenceService.markEpisodes(ids: self.episodes!.map { $0.id }, watched: true)
            self.episodes = PersistenceService.getEpisodes(show: self.showID)
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Watchn't", style: .default, handler: { (alertAction) in
            PersistenceService.markEpisodes(ids: self.episodes!.map { $0.id }, watched: false)
            self.episodes = PersistenceService.getEpisodes(show: self.showID)
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let s = seasons {
            return s.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seasonCell", for: indexPath)
        
        if let _ = seasons {
            cell.textLabel?.text = "Season \(seasons![indexPath.row])"
            
            // If the show doesn't have a 'Season 0' (i.e. special episodes), -1 the airedSeason so that season equals indexPath.row
            if (self.episodes?.contains(where: { $0.airedSeason == 0 }) ?? false) {
                cell.detailTextLabel?.text = "\(self.episodes!.filter{($0.airedSeason!) == indexPath.row}.count) Episodes"
            } else {
                cell.detailTextLabel?.text = "\(self.episodes!.filter{($0.airedSeason!-1) == indexPath.row}.count) Episodes"
            }
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
            episodeVC.showID = showID
            if (self.episodes?.contains(where: { $0.airedSeason == 0 }) ?? false) {
                episodeVC.episodes = self.episodes!.filter{ $0.airedSeason! == indexPath.row }
            } else {
                episodeVC.episodes = self.episodes!.filter{ $0.airedSeason!-1 == indexPath.row }
            }
        }
    }
    
    
}
