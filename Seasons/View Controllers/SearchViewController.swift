//
//  SearchViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 3/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit
import os

class SearchViewController : UITableViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var searchResults = [TMSearchResult]()
    
    let searchController = UISearchController(searchResultsController: nil)
    let greenysFavouriteShows = [
        "Mr. Robot",
        "Game of Thrones",
        "Westworld",
        "Brooklyn Nine-Nine",
        "The Office (US)",
        "Parks and Recreation",
        "Rick and Morty",
        "Sherlock",
        "Silicon Valley",
        "Stranger Things",
        "Suits",
        "The Good Place",
        "The I.T. Crowd",
        "Marvel's Daredevil",
        "Marvel's Jessica Jones",
        "Marvel's The Punisher",
        "Black Mirror",
        "Atlanta",
        "Arrested Development",
        "Arrow",
        "Breaking Bad"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        // so we can still tap on the tableview
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        tableView.register(UINib(nibName: "ShowTableViewCell", bundle: nil), forCellReuseIdentifier: "showCell")
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        // This is broken in iOS 13(.1) - the Navigation Bar in the child controller overlaps the previous' controller's content for a brief second.
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.autocorrectionType = .yes
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchController.searchBar.placeholder = greenysFavouriteShows.randomElement()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let query = searchBar.text else {
            return
        }
        
        for cell in (tableView.visibleCells as? [ShowTableViewCell])! {
            cell.backgroundImageView.image = nil
        }
        searchResults.removeAll()
        tableView.reloadData()
        
        TMDBAPI.searchShows(query: query) { results in
            if let showResults = results {
                self.searchResults = showResults
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                for result in showResults {
                    os_log("Show Name: %@", log: .networking, type: .debug, result.name)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedTableViewCell = sender as? ShowTableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a ShowTableViewCell") }
        
        guard let showVC = segue.destination as? ShowViewController
            else { preconditionFailure("Expected a ShowViewController") }
        
        if segue.identifier == "segueToShow" {
            let searchResult = searchResults[indexPath.row]
            let show = searchResult.convertToShow()
            showVC.show = show
            PersistenceService.temporaryContext.delete(show)
        }
    }
}

// MARK: - Delegate/Helper Methods
extension SearchViewController : UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        return
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.beginUpdates()

        for i in 0..<searchResults.count {
            let indexPath = IndexPath(row: i, section: 0)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
        searchResults.removeAll()
        tableView.endUpdates()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell
        
        if searchResults.count != 0 {
            let show = searchResults[indexPath.row]
            // cell.show = show
            cell.titleLabel.text = show.name
            cell.detailLabel.text = show.overview
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "segueToShow", sender: tableView.cellForRow(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
