//
//  HomeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 1/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

//view controller used for home tab - show favourite shows, etc

import Foundation
import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var favouriteShows = [FavouriteShows]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
        updateFavouriteShows()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedTableViewCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a valid table view cell") }
        
        guard let showVC = segue.destination as? ShowViewController
            else { preconditionFailure("Expected a ShowViewController") }
        
        if segue.identifier == "HomeToShow" {
            let show = favouriteShows[indexPath.row]
            showVC.show = Show(id: show.id, overview: show.overview!, seriesName: show.seriesName ?? "Shit", banner: show.banner ?? "", status: show.status ?? "Unknown", runtime: show.runtime ?? "Unknown", network: show.network ?? "Unknown")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func updateFavouriteShows() {
        let fetchRequest: NSFetchRequest<FavouriteShows> = FavouriteShows.fetchRequest()
        do {
            let shows = try PersistenceService.context.fetch(fetchRequest)
            self.favouriteShows = shows
            print("Updated favourite show list.")
        } catch {
            print(error, error.localizedDescription)
        }
        
        tableView.reloadData()
    }
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favouriteShows.isEmpty {
            return 1
        }
        
        return favouriteShows.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "favouriteShowsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        if (favouriteShows.isEmpty) {
            cell.textLabel?.text = "No Favourites!"
            cell.detailTextLabel?.text = "Head to the search tab to find some shows!"
            cell.isUserInteractionEnabled = false
        } else {
            cell.textLabel?.text = favouriteShows[indexPath.row].seriesName
            cell.detailTextLabel?.text = favouriteShows[indexPath.row].overview
            cell.isUserInteractionEnabled = true
        }
        
        /* SearchTableViewCell Code - currently doesn't work as I believe we need to use a nib (template)
         let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteShowsCell") as! SearchTableViewCell
         
         if (favouriteShows.isEmpty) {
         cell.titleLabel?.text = "No Favourites!"
         cell.detailLabel?.text = "Head to the search tab to find some shows!"
         } else {
         let currentShow = favouriteShows[indexPath.row]
         cell.show = Show(id: currentShow.id, overview: currentShow.overview, seriesName: currentShow.seriesName, banner: currentShow.banner ?? "", status: currentShow.status ?? "Unknown", runtime: currentShow.runtime ?? "Unknown", network: currentShow.network ?? "Unknown")
         }
         */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (favouriteShows.isEmpty) {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if (!favouriteShows.isEmpty) {
            print("Favourite Shows: ", favouriteShows)
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                PersistenceService.deleteEntity(id: self.favouriteShows[indexPath.row].id)
                self.updateFavouriteShows()

                // TODO: Change this to deleteRow to get that sweet animation however at the same time don't crash due to a UITableView inconsistency error.
                tableView.reloadData()
            }

            return [delete]
        }
        return nil
    }
}
