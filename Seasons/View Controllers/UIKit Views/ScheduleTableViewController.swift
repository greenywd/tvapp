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
    var favouriteShows: [Int32]! {
        return PersistenceService.getShows().map { $0.id }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let currentDate = Date()
        
        if let favEpisodes = PersistenceService.getEpisodes(show: favouriteShows) {
            episodes = favEpisodes.filter { $0.firstAired ?? Date(timeInterval: 0, since: currentDate) > currentDate }.sorted(by: { (ep1, ep2) -> Bool in
                return ep2.firstAired! > ep1.firstAired!
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentDate = Date()
        
        if let favEpisodes = PersistenceService.getEpisodes(show: favouriteShows) {
            episodes = favEpisodes.filter { $0.firstAired ?? Date(timeInterval: 0, since: currentDate) > currentDate }.sorted(by: { (ep1, ep2) -> Bool in
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
