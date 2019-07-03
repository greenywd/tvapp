//
//  ShowEpisodeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 18/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowEpisodeViewController: UITableViewController {
    
    var id: Int32?
    var episodes: [Episode]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if episodes == nil {
            TVDBAPI.getEpisodes(show: id!) {
                if let episodes = $0 {
                    self.episodes = episodes
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        dump(episodes!)
        
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
        
        // TODO: Ensure episodes are in order (Season > Episode?, i.e. 1x01, 1x02, etc)
        if let episodes = self.episodes {
            cell.episode = episodes[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "episodesToEpisode", sender: tableView.cellForRow(at: indexPath))
    }
}
