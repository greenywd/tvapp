//
//  ScheduleTableViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 3/7/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {
    
    var episodes: [Episode]?
    var airDates: [Date]?
    
    lazy var segmentedControl = UISegmentedControl(items: ["Upcoming", "Unwatched"])
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "showCell")
        tableView.rowHeight = 90
        
        segmentedControl.sizeToFit()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        tableView.tableHeaderView = segmentedControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEpisodeDataSource()
        tableView.reloadData()
    }
    
    private func updateEpisodeDataSource() {
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.episodes = PersistenceService.getEpisodes(filterUpcoming: true)
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            self.episodes = PersistenceService.getEpisodes(filterUnwatched: true, filterUpcoming: false)
        }
        
        if let eps = episodes {
            self.airDates = Array(Set(eps.map { $0.firstAired })).sorted {
                return $1 >= $0
            }
        }
    }
    
    @objc func segmentedControlChanged(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        updateEpisodeDataSource()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = episodes {
            return airDates?.count ?? 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DateFormatter.cached(type: .friendly).string(from: airDates![section])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (episodes?.filter({ $0.firstAired == airDates![section]}).count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath) as! ShowTableViewCell
        
        let section = airDates![indexPath.section]
        let filteredEpisodes = episodes!.filter { $0.firstAired == section }
        
        cell.titleLabel.text = filteredEpisodes[indexPath.row].episodeName ?? "Unknown Title"
        cell.detailLabel.text = filteredEpisodes[indexPath.row].overview ?? "No Description" // DateFormatter().string(from: episode.firstAired!)
        
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
