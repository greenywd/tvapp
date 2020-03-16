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
import os

class HomeViewController: UITableViewController {
    
    var favouriteShows = [Show]()
    var filteredFavouriteShows = [Show]()
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let alert = UIAlertController(title: "Migration of API", message: """
            With recent issues at TheTVDB, I've decided to move tvapp to TheMovieDB instead. Despite their name, they have a lot more information useful for tvapp, and will enable lots of new features. Stay tuned!
            
            As such, your favourites will need to be migrated over to TheMovieDB in order to continue working. This can be done at a later date, however I suggest you do it as soon as possible.
            """, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Later", style: .default, handler: nil))
        let migrateAction = UIAlertAction(title: "Migrate", style: .default, handler: { _ in
            // TODO: Implement migration
        })
        alert.addAction(migrateAction)
        alert.preferredAction = migrateAction
//        present(alert, animated: true, completion: nil)
        
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "showCell")
        tableView.rowHeight = 90
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search Shows"
        navigationItem.searchController = searchController
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        os_log("Received notification: %@.", log: .ui, notification.debugDescription)
        DispatchQueue.main.async {
            self.updateFavouriteShows()
        }
    }
    
    @objc func refresh() {
        PersistenceService.context.refreshAllObjects()
        refreshControl?.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavouriteShows()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homeToSettings") {
            guard let settingsNC = segue.destination as? UINavigationController else {
                preconditionFailure("Expected SettingsRootViewController")
            }
            (settingsNC.topViewController as! SettingsRootViewController).wasPresentedViaModel = true
            return
        }
        guard let selectedTableViewCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a valid table view cell") }
        
        guard let showVC = segue.destination as? ShowViewController
            else { preconditionFailure("Expected a ShowViewController") }
        
        if segue.identifier == "segueToShow" {
            showVC.show = isFiltering() ? filteredFavouriteShows[indexPath.row] : favouriteShows[indexPath.row]
        }
    }
    
    func updateFavouriteShows() {
        if let shows = PersistenceService.getShows() {
            favouriteShows = shows.sorted(by: { $1.seriesName!.lowercased() > $0.seriesName!.lowercased() })
        } else {
            favouriteShows.removeAll()
            self.refreshControl?.endRefreshing()
        }
        tableView.reloadData()
    }
}


// MARK: - Delegate/Helper Methods
extension HomeViewController : UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredFavouriteShows = favouriteShows.filter({ show -> Bool in
            return show.seriesName!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favouriteShows.isEmpty {
            return 1
        } else if isFiltering() {
            return filteredFavouriteShows.count
        }
        
        return favouriteShows.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (favouriteShows.isEmpty && filteredFavouriteShows.isEmpty) {
            tabBarController?.selectedIndex = 2
            return
        }
        performSegue(withIdentifier: "segueToShow", sender: tableView.cellForRow(at: indexPath))
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell
        
        if (favouriteShows.isEmpty) {
            print(favouriteShows)
            cell = noFavouritesRow
        } else {
            let show = isFiltering() ? filteredFavouriteShows[indexPath.row] : favouriteShows[indexPath.row]
            cell.show = show
            cell.titleLabel.text = show.seriesName
            cell.detailLabel.text = show.overview
            
            if let backgroundImageData = show.bannerImage {
                if let backgroundImage = UIImage(data: backgroundImageData) {
                    cell.backgroundImageView.image = backgroundImage
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !favouriteShows.isEmpty
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
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if (!favouriteShows.isEmpty) {
            let showID = favouriteShows[indexPath.row].id
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                
                let watched = UIAction(title: "Watched", image: UIImage(systemName: "tv.fill")) { action in
                    PersistenceService.markEpisodes(for: showID, watched: true)
                }
                
                let unwatched = UIAction(title: "Watchn't", image: UIImage(systemName: "tv")) { action in
                    PersistenceService.markEpisodes(for: showID, watched: false)
                }
                
                return UIMenu(title: "Mark Show as:", children: [watched, unwatched])
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.preferredCommitStyle = .dismiss
    }
    
    var noFavouritesRow: ShowTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell
        cell.titleLabel?.text = "No Favourites!"
        cell.detailLabel?.text = "Head to the search tab to find some shows!"
        cell.backgroundImageView.image = nil
        
        return cell
    }
}
