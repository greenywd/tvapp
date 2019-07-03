//
//  SearchViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 3/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController : UITableViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var searchResults = [Show]()
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
        "Arrow"
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
        // FIXME: This is broken in iOS 13 beta 2 - change to false later
        searchController.obscuresBackgroundDuringPresentation = true
 
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
            }
            
            if let results = results {
                self.searchResults = results
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
            showVC.show = searchResults[indexPath.row]
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
            cell.show = searchResults[indexPath.row]
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
