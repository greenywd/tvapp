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
        
        if let episodes = PersistenceService.getEpisodes(show: showID) {
            self.episodes = episodes
        } else {
            TVDBAPI.getEpisodes(show: showID) { (episodeList) in
                if let episodes = episodeList {
                    self.episodes = episodes
                    // Get number of episodes in season
                    // let seasons = self.episodes!.filter{$0.airedSeason! == 5}.count
                    self.seasons = Set((episodeList ?? []).compactMap { $0.airedSeason }).sorted()
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = seasons {
            return seasons!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seasonCell", for: indexPath)
        
        if let _ = seasons {
            cell.textLabel?.text = "Season \(seasons![indexPath.row])"
            cell.detailTextLabel?.text = "\(self.episodes!.filter{$0.airedSeason! == indexPath.row}.count) Episodes"
        }
        
        // Configure the cell...
        print("configured cell")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
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
            episodeVC.episodes = self.episodes!.filter{$0.airedSeason! == indexPath.row}
        }
    }
    
    
}