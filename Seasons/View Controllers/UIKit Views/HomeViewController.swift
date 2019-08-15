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
    
    var favouriteShows = [Show]()
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
            showVC.show = show
        }
    }
    
    func updateFavouriteShows() {
        favouriteShows = PersistenceService.getShows()
        
        tableView.reloadData()
    }
}


// MARK: - Delegate/Helper Methods
extension HomeViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        return
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
            tabBarController?.selectedIndex = 2
            return
        }
        performSegue(withIdentifier: "segueToShow", sender: tableView.cellForRow(at: indexPath))

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell

         if (favouriteShows.isEmpty) {
            cell = noFavouritesRow()
         } else {
            cell.show = favouriteShows[indexPath.row]
            
            if let backgroundImageData = favouriteShows[indexPath.row].bannerImage {
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
                PersistenceService.deleteShow(id: self.favouriteShows[indexPath.row].id)
                self.favouriteShows.remove(at: indexPath.row)
                
                if self.favouriteShows.isEmpty {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
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
