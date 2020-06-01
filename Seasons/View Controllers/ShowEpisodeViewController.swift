//
//  ShowEpisodeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 18/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowEpisodeViewController: UITableViewController {
    
    var showID: Int32 = 0
    var seasonNumber: Int16 = 0
    
    var episodes: [Episode]? {
        didSet {
            episodes = episodes?.sorted(by: { (ep1, ep2) -> Bool in
                ep1.episodeNumber < ep2.episodeNumber
            })
        }
    }
    
    let cache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = seasonNumber == 0 ? "Specials/Extras" : "Season \(seasonNumber)"
        
        if (PersistenceService.showExists(id: showID)) {
            episodes = PersistenceService.getEpisodes(show: showID, season: seasonNumber)
            
            let markWatchedButtonItem = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext"), style: .plain, target: self, action: #selector(markEpisodes))
            navigationItem.rightBarButtonItem = markWatchedButtonItem
        } else {
            TMDBAPI.getEpisodes(show: showID, season: seasonNumber, completion: { (episodes) in
                if let unwrappedEpisodes = episodes {
                    self.episodes = unwrappedEpisodes
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }
        
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "showCell")
        
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
            
            PersistenceService.markEpisodes(for: self.showID, inSeason: self.seasonNumber, watched: true)
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Unwatched", style: .default, handler: { (alertAction) in
            PersistenceService.markEpisodes(for: self.showID, inSeason: self.seasonNumber, watched: false)
        }))
        
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedTableViewCell = sender as? ShowTableViewCell,
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell
        
        if let episodes = self.episodes {
            let episode = episodes[indexPath.row]
            
            cell.titleLabel.text = episode.name
            cell.detailLabel.text = episode.overview
            
            if let image = episode.image {
                cell.backgroundImageView.image = UIImage(data: image)
            } else {
                if let stillPath = episode.stillPath {
                    if let cachedImage = self.cache.object(forKey: NSString(string: "\(episode.id)")) {
                        cell.backgroundImageView.image = cachedImage
                    } else {
                        DispatchQueue.global(qos: .userInteractive).async {
                            let dataForImage = try? Data(contentsOf: TMDBAPI.createImageURL(path: stillPath)!)
                            if let image = dataForImage {
                                let compressedImage = UIImage(data: image)!.jpegData(compressionQuality: 0.85)!
                                DispatchQueue.main.async {
                                    if PersistenceService.showExists(id: episode.showID) {
                                        episode.image = compressedImage
                                        PersistenceService.saveContext()
                                    }
                                    
                                    cell.backgroundImageView.image = UIImage(data: compressedImage)
                                    self.cache.setObject(cell.backgroundImageView.image!, forKey: NSString(string: "\(episode.id)"))
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if(!episodes!.isEmpty) {
            if let _ = PersistenceService.getShow(id: showID) {
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
