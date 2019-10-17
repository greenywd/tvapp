//
//  ScheduleTableViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 3/7/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {
    
    var episodes: [Episode]? {
        didSet {
            print("NUMBER OF NONFILTERED EPISODES \(episodes?.count)")
            episodes = episodes?.filter({ $0.firstAired != nil && $0.firstAired! > Date() }).sorted(by: { (ep1, ep2) -> Bool in
                return ep2.firstAired! > ep1.firstAired!
            })
            print("NUMBER OF FILTERED EPISODES \(episodes?.count)")
            tableView.reloadData()
        }
    }
    var favouriteShows: [Int32]? {
        return PersistenceService.getShows()?.map { $0.id }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "showCell")
        tableView.rowHeight = 90
        
        let segment: UISegmentedControl = UISegmentedControl(items: ["Upcoming", "Unwatched"])
        segment.sizeToFit()
        segment.selectedSegmentIndex = 0
        tableView.tableHeaderView = segment
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        episodes = PersistenceService.getEpisodes(show: favouriteShows!)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let eps = episodes {
            return Set<Date>(eps.map{ $0.firstAired! }).count
        }
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedTableViewCell = sender as? ShowTableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a valid table view cell") }
        
        guard let episodeVC = segue.destination as? EpisodeTableViewController
            else { preconditionFailure("Expected a EpisodeTableViewController") }
        
        if segue.identifier == "scheduleToEpisode" {
            episodeVC.episode = episodes![indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM"
        
        return episodes!.map { dateFormatter.string(from: $0.firstAired!) }[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (episodes?.filter({ $0.firstAired == episodes![section].firstAired}).count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath) as! ShowTableViewCell
        
        if let episodes = episodes?.filter({ $0.firstAired! == episodes!.map { $0.firstAired! }[indexPath.section] }) {
            for episode in episodes {
                cell.titleLabel.text = episode.episodeName ?? "Unknown Title"
                cell.detailLabel.text = episode.overview ?? "No Description" // DateFormatter().string(from: episode.firstAired!)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "scheduleToEpisode", sender: tableView.cellForRow(at: indexPath))
    }
}
