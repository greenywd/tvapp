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
    
    var searchResultsTMDB = [TMSearchResult]()
    var searchResultsTVDB = [Show]()
    
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
        UserDefaults.standard.bool(forKey: "migrateTMDB") ? searchResultsTMDB.removeAll() : searchResultsTVDB.removeAll()
        tableView.reloadData()
        
        if (UserDefaults.standard.bool(forKey: "migrateTMDB")) {
            TMDBAPI.searchShows(query: query) { results in
                if let showResults = results {
                    self.searchResultsTMDB = showResults
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    for result in showResults {
                        os_log("Show Name: %@", log: .networking, type: .debug, result.name)
                    }
                }
            }
        } else {
            TVDBAPI.searchShows(show: query) { (results, error) in
                if let error = error {
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "No Shows Found", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Detail", style: .default, handler: { (action) in
                            let detailAlert = UIAlertController(title: "Detail", message: error, preferredStyle: .alert)
                            detailAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                            self.present(detailAlert, animated: true, completion: nil)
                        }))
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                        self.tableView.reloadData()
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return
                } else if let results = results {
                    self.searchResultsTVDB = results
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
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
            if (UserDefaults.standard.bool(forKey: "migrateTMDB")) {
                let searchResult = searchResultsTMDB[indexPath.row]
                showVC.showTM = TMShow(from: searchResult)
            } else {
                showVC.show = searchResultsTVDB[indexPath.row]
            }
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
        if (UserDefaults.standard.bool(forKey: "migrateTMDB")) {
            for i in 0..<searchResultsTMDB.count {
                let indexPath = IndexPath(row: i, section: 0)
                tableView.deleteRows(at: [indexPath], with: .right)
            }
            searchResultsTMDB.removeAll()
            tableView.endUpdates()
        } else {
            for i in 0..<searchResultsTVDB.count {
                let indexPath = IndexPath(row: i, section: 0)
                tableView.deleteRows(at: [indexPath], with: .right)
            }
            searchResultsTVDB.removeAll()
            tableView.endUpdates()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaults.standard.bool(forKey: "migrateTMDB") ? searchResultsTMDB.count : searchResultsTVDB.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell") as! ShowTableViewCell
        
        if (UserDefaults.standard.bool(forKey: "migrateTMDB")) {
            if searchResultsTMDB.count != 0 {
                let show = searchResultsTMDB[indexPath.row]
                // cell.show = show
                cell.titleLabel.text = show.name
                cell.detailLabel.text = show.overview
            }
        } else {
            if searchResultsTVDB.count != 0 {
                let show = searchResultsTVDB[indexPath.row]
                // cell.show = show
                cell.titleLabel.text = show.seriesName
                cell.detailLabel.text = show.overview
            }
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
