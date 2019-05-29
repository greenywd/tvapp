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
    
    var searchResults: [Show]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        // so we can still tap on the tableview
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
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
        activityIndicator.startAnimating()
        
        guard let query = searchBar.text else {
            return
        }
        
        for cell in (tableView.visibleCells as? [SearchTableViewCell])! {
            cell.backgroundImage.image = nil
        }
        
        TVDBAPI.searchShows(show: query) {
            if let results = $0 {
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
        
        print("MOVING TO:", segue.destination)
        
        guard let results = searchResults else {
            return
        }

        guard let selectedTableViewCell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: selectedTableViewCell)
            else { preconditionFailure("Expected sender to be a valid table view cell") }
        
        guard let showVC = segue.destination as? ShowViewController
            else { preconditionFailure("Expected a ShowViewController") }
        
        if segue.identifier == "segueToShow" {
            showVC.show = results[indexPath.row]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SearchTableViewCell
        
        if let results = searchResults {
            if let url = URL(string: "https://www.thetvdb.com/banners/" + results[indexPath.row].banner!) {

                if cell.backgroundImage.image == nil {
                    DispatchQueue.global(qos: .background).async {
                        let dataForImage = try? Data(contentsOf: url)
                        
                        DispatchQueue.main.async {
                            if let image = dataForImage {
                                cell.backgroundImage.image = UIImage(data: image)
                            }
                        }
                    }
                }
            }
            
            cell.titleLabel.text = results[indexPath.row].seriesName
            cell.detailLabel.text = results[indexPath.row].overview
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue being performed in Storyboard
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}
