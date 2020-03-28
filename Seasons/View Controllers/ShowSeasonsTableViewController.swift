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
    var seasons: [Season]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check to see if we've got the show favourited and load the episodes from CoreData if we do.
        // If not, download them
        if let seasons = self.seasons {
            if let show = PersistenceService.getShow(id: showID) {
                self.seasons = show.seasons?.allObjects as? [Season]
                
                let markWatchedButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext"), style: .plain, target: self, action: #selector(markEpisodes))
                navigationItem.rightBarButtonItem = markWatchedButtonItem
                
            } else {
                // TODO: Download seasons (from /tv/?)
            }
        }
    }
    
    @objc func markEpisodes() {
        let alertSheet = UIAlertController(title: "Mark All Seasons as:", message: nil, preferredStyle: .actionSheet)
        alertSheet.addAction(UIAlertAction(title: "Watched", style: .default, handler: { (alertAction) in
            // TODO: Mark all seasons as watched
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Unwatched", style: .default, handler: { (alertAction) in
            // TODO: Mark all seasons as unwatched
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
        if let seasons = self.seasons {
            return seasons.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seasonCell", for: indexPath)
        
        // TODO: Setup cells
        if let seasons = self.seasons {
            cell.textLabel!.text = "Season \(seasons[indexPath.row].seasonNumber)"
            cell.detailTextLabel!.text = "\(seasons[indexPath.row].episodeCount) episodes"
        }
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
        }
    }
    
    
}
