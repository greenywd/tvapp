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
            tableView.reloadData()
        }
    }
    var favouriteShows: [Int32]? {
        return PersistenceService.getShows()?.map { $0.id }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let currentDate = Date()
        
        if let favEpisodes = favouriteShows, let shows = PersistenceService.getEpisodes(show: favEpisodes) {
            episodes = shows.filter { $0.firstAired ?? Date(timeInterval: 0, since: currentDate) > currentDate }.sorted(by: { (ep1, ep2) -> Bool in
                return ep2.firstAired! > ep1.firstAired!
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentDate = Date()
        
        if let favEpisodes = favouriteShows, let shows = PersistenceService.getEpisodes(show: favEpisodes) {
            episodes = shows.filter { $0.firstAired ?? Date(timeInterval: 0, since: currentDate) > currentDate }.sorted(by: { (ep1, ep2) -> Bool in
                return ep2.firstAired! > ep1.firstAired!
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let eps = episodes {
            return Set<Date>(eps.map{ $0.firstAired! }).count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM"
        
        return episodes!.map { dateFormatter.string(from: $0.firstAired!) }[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (episodes?.map{ $0.firstAired! == episodes!.map{ $0.firstAired! }[section] }.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let episodes = episodes?.filter({ $0.firstAired! == episodes!.map { $0.firstAired! }[indexPath.section] }) {
            for episode in episodes {
                cell.textLabel?.text = episode.episodeName
                cell.detailTextLabel?.text = DateFormatter().string(from: episode.firstAired!)
            }
        }
        
        // Configure the cell...
        
        return cell
    }
}
