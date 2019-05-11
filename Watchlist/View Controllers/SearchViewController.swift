//
//  SearchViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 3/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController : UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var cellIndex = 0
    var searchResults: [SearchResults.Data]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        
        // so we can still tap on the tableview
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 90
        tableView.layoutMargins = .zero
        //        tableView.separatorInset = .zero
        //        tableView.separatorStyle = .none
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.activityIndicator.startAnimating()
        
        guard let query = searchBar.text else {
            return
        }
        
        API.searchSeries(series: query, using: TVDBAPI.token) { (results) in
            if let results = results?.data {
                self.searchResults = results
            }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
        self.searchBar.endEditing(true)
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.keyboardAppearance = .dark
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let results = searchResults else {
            return
        }
        
        if segue.identifier == "segue" {
            if let showVC = segue.destination as? ShowViewController {
                showVC.showFromSearch = results[cellIndex]
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SearchViewController : UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = searchResults {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = searchResults {
            return results.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellIdentifier)
        
        if let results = searchResults {
            cell.textLabel?.text = results[indexPath.row].seriesName
            print(results[indexPath.row].seriesName)
            cell.textLabel?.numberOfLines = 1
            cell.textLabel?.lineBreakMode = .byTruncatingTail
            cell.textLabel?.textColor = UIColor.white
            
            cell.detailTextLabel?.text = results[indexPath.row].overview
            cell.detailTextLabel?.numberOfLines = 3
            cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
            cell.detailTextLabel?.textColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        cellIndex = indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
    }
}
