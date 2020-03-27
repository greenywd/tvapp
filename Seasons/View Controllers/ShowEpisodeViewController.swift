//
//  ShowEpisodeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 18/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowEpisodeViewController: UITableViewController {
    
    var showID: Int32?
    var airedSeason: Int16?
    
    var episodes: [Episode]? {
        didSet {
            self.airedSeason = episodes?.first?.seasonNumber
            episodes = episodes?.sorted(by: { (ep1, ep2) -> Bool in
                ep1.episodeNumber < ep2.episodeNumber
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if episodes == nil {
            TMDBAPI.getEpisodes(show: showID!, season: airedSeason!, completion: { (episodes) in
                if let unwrappedEpisodes = episodes {
                    self.episodes = unwrappedEpisodes
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        
        if (PersistenceService.showExists(id: showID!)) {
            let markWatchedButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext"), style: .plain, target: self, action: #selector(markEpisodes))
            navigationItem.rightBarButtonItem = markWatchedButtonItem
        }
        
        tableView.register(UINib(nibName: "EpisodeTableViewCell", bundle: nil), forCellReuseIdentifier: "episodeCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func markEpisodes() {
        let alertSheet = UIAlertController(title: "Mark All Episodes as:", message: nil, preferredStyle: .actionSheet)
        alertSheet.addAction(UIAlertAction(title: "Watched", style: .default, handler: { (alertAction) in
            
            PersistenceService.markEpisodes(for: self.showID!, inSeason: self.airedSeason!, watched: true)
            self.episodes = PersistenceService.getEpisodes(show: self.showID!, season: self.airedSeason!)
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Watchn't", style: .default, handler: { (alertAction) in
            PersistenceService.markEpisodes(for: self.showID!, inSeason: self.airedSeason!, watched: false)
            self.episodes = PersistenceService.getEpisodes(show: self.showID!, season: self.airedSeason!)
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedTableViewCell = sender as? EpisodeTableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a EpisodeTableViewCell") }
        
        guard let episodeVC = segue.destination as? EpisodeTableViewController
            else { preconditionFailure("Expected a EpisodeTableViewController") }
        
        if segue.identifier == "episodesToEpisode" {
            episodeVC.headerImage = selectedTableViewCell.backgroundImageView.image
            episodeVC.episode = episodes![indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let episodes = self.episodes {
            return episodes.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell") as! EpisodeTableViewCell
        
        if let episodes = self.episodes {
            cell.episode = episodes[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if(!episodes!.isEmpty) {
            if let _ = PersistenceService.getShow(id: showID!) {
                let episode = episodes![indexPath.row]
                
                if (episode.hasWatched == true) {
                    let unwatchItem = UIContextualAction(style: .normal, title: "Watchn't") { (action, view, success) in
                        self.episodes![indexPath.row].hasWatched = false
                        PersistenceService.markEpisode(id: episode.id, watched: false)
                        success(true)
                    }
                    return UISwipeActionsConfiguration(actions: [unwatchItem])
                } else {
                    let watchItem = UIContextualAction(style: .normal, title: "Watched") { (action, view, success) in
                        self.episodes![indexPath.row].hasWatched = true
                        PersistenceService.markEpisode(id: episode.id, watched: true)
                        success(true)
                    }
                    return UISwipeActionsConfiguration(actions: [watchItem])
                }
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "episodesToEpisode", sender: tableView.cellForRow(at: indexPath))
    }
}
