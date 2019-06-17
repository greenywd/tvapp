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

class HomeViewController: UITableViewController {
    
    var favouriteShows = [CD_Show]()
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "showCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Shows"
        navigationItem.searchController = searchController
        // navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
        let searchBarHeight = searchController.searchBar.frame.size.height
        tableView.setContentOffset(CGPoint(x: 0, y: searchBarHeight), animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        updateFavouriteShows()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        // self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedTableViewCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a valid table view cell") }
        
        guard let showVC = segue.destination as? ShowViewController
            else { preconditionFailure("Expected a ShowViewController") }
        
        if segue.identifier == "segueToShow" {
            let show = favouriteShows[indexPath.row]
            showVC.show = Show(id: show.id, overview: show.overview ?? "Overview", seriesName: show.seriesName ?? "Series Name", banner: show.banner ?? "", status: show.status ?? "Unknown", runtime: show.runtime ?? "Unknown", network: show.network ?? "Unknown", siteRating: show.siteRating, siteRatingCount: show.siteRatingCount)
        }
    }
    
    func updateFavouriteShows() {
        let fetchRequest: NSFetchRequest<CD_Show> = CD_Show.fetchRequest()
        do {
            let shows = try PersistenceService.context.fetch(fetchRequest)
            self.favouriteShows = shows
        } catch {
            print(error, error.localizedDescription)
        }
        
        tableView.reloadData()
    }
}


// MARK: - Delegate/Helper Methods
extension HomeViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favouriteShows.isEmpty {
            return 1
        }
        
        return favouriteShows.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (favouriteShows.isEmpty) {
            return
        }
        performSegue(withIdentifier: "segueToShow", sender: tableView.cellForRow(at: indexPath))

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell

         if (favouriteShows.isEmpty) {
            cell = noFavouritesRow()
         } else {
            let currentShow = favouriteShows[indexPath.row]
            cell.show = Show(id: currentShow.id, overview: currentShow.overview, seriesName: currentShow.seriesName, banner: currentShow.banner ?? "", status: currentShow.status ?? "Unknown", runtime: currentShow.runtime ?? "Unknown", network: currentShow.network ?? "Unknown", siteRating: currentShow.siteRating, siteRatingCount: currentShow.siteRatingCount)
            
            if let backgroundImageData = currentShow.bannerImage {
                if let backgroundImage = UIImage(data: backgroundImageData) {
                    cell.backgroundImageView.image = backgroundImage
                }
            }
         }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (favouriteShows.isEmpty) {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if(!favouriteShows.isEmpty) {
            let deleteItem = UIContextualAction(style: .destructive, title: "Delete") { (action, view, success) in
                PersistenceService.deleteEntity(id: self.favouriteShows[indexPath.row].id)
                self.favouriteShows.remove(at: indexPath.row)
                
                if self.favouriteShows.isEmpty {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .right)
                }

                self.updateFavouriteShows()
                success(true)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteItem])
        }
        return nil
    }
    
    func noFavouritesRow() -> ShowTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell
        cell.titleLabel?.text = "No Favourites!"
        cell.detailLabel?.text = "Head to the search tab to find some shows!"
        cell.backgroundImageView.image = nil
        
        return cell
    }
}
