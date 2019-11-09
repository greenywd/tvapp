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
            episodes = episodes?.filter({ $0.firstAired != nil && $0.firstAired! >= Date() }).sorted(by: { (ep1, ep2) -> Bool in
                return ep2.firstAired! >= ep1.firstAired!
            })
            print(episodes!.map { $0.episodeName })
            tableView.reloadData()
        }
    }
    
    var airDates: [Date]? {
        return Array(Set(episodes!.map { $0.firstAired! })).sorted(by: { (d1, d2) -> Bool in
                return d2 >= d1
        })
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
        
        let segment: UISegmentedControl = UISegmentedControl(items: ["Upcoming"]) // Add back "Unwatched"
        segment.sizeToFit()
        segment.selectedSegmentIndex = 0
        tableView.tableHeaderView = segment
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let favourites = favouriteShows {
            episodes = PersistenceService.getEpisodes(show: favourites)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = episodes {
            return airDates?.count ?? 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM"
        
        let date = airDates![section]
        return dateFormatter.string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (episodes?.filter({ $0.firstAired == airDates![section]}).count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath) as! ShowTableViewCell
        
        if (episodes != nil && !episodes!.isEmpty) {
            let section = airDates![indexPath.section]
            let filteredEpisodes = episodes!.filter { $0.firstAired == section }
        
            cell.titleLabel.text = filteredEpisodes[indexPath.row].episodeName ?? "Unknown Title"
            cell.detailLabel.text = filteredEpisodes[indexPath.row].overview ?? "No Description" // DateFormatter().string(from: episode.firstAired!)
        }
        return cell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // performSegue(withIdentifier: "scheduleToEpisode", sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
