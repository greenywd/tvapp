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
    var airDates: [Date?]?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "showCell")
        tableView.rowHeight = 90
        
        setupSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEpisodeDataSource()
        tableView.reloadData()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }
    
    private func updateEpisodeDataSource() {
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.episodes = PersistenceService.getEpisodes(filterUpcoming: true)
        } else if (segmentedControl.selectedSegmentIndex == 1) {
            self.episodes = PersistenceService.getEpisodes(filterUnwatched: true, filterUpcoming: false)
        }
        
        if let eps = episodes {
            self.airDates = Array(Set(eps.map { $0.airDate })).sorted { (lhs, rhs) -> Bool in
                return (lhs ?? Date.distantPast) > (rhs ?? Date.distantPast)
            }
        }
    }
    
    @objc func segmentedControlChanged(sender: UISegmentedControl) {
        updateEpisodeDataSource()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = episodes {
            return airDates?.count ?? 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let dates = airDates else {
            return "Unknown Date"
        }
        
        guard let date = dates[section] else {
            return "Unknown Date"
        }
        
        return DateFormatter.cached(type: .friendly).string(from: date)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rowCount = episodes?.filter({ $0.airDate == airDates![section]}).count {
            return rowCount
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath) as! ShowTableViewCell
        if !episodes!.isEmpty {
            let section = airDates![indexPath.section]
            let filteredEpisodes = episodes!.filter { $0.airDate == section }
            // FIXME: This holds up the UI for quite a bit, perhaps try one of those fancy background contexts?
            let show = PersistenceService.getShow(id: filteredEpisodes[indexPath.row].showID)
            cell.titleLabel.text = "\(filteredEpisodes[indexPath.row].name ?? "Unknown Episode Name") - \(show?.name! ?? "Unknown Show Name")"
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
            let sectionEpisodes = episodes!.filter { $0.airDate == airDates![indexPath.section] }
            episodeVC.episode = sectionEpisodes[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "scheduleToEpisode", sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (segmentedControl.selectedSegmentIndex == 1) {
            let section = airDates![indexPath.section]
            let episode = episodes!.filter { $0.airDate == section }[indexPath.row]
            
            if let _ = PersistenceService.getShow(id: episode.showID) {
                let watchItem = UIContextualAction(style: .normal, title: "Watched") { (action, view, success) in
                    self.episodes![indexPath.row].hasWatched = true
                    PersistenceService.markEpisode(id: episode.id, watched: true)
                    
                    // Perhaps use multi-dimensional arrays instead? Should be a bit faster than filtering over everything.
                    self.episodes = self.episodes?.filter { $0.id != episode.id }
                    
                    if self.episodes!.isEmpty {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    } else {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        
                        if (tableView.numberOfRows(inSection: indexPath.section) == 0) {
                            self.airDates?.remove(at: indexPath.section)
                            tableView.deleteSections([indexPath.section], with: .automatic)
                        }
                    }
                    
                    success(true)
                }
                return UISwipeActionsConfiguration(actions: [watchItem])
            }
        }
        return nil
    }
}
