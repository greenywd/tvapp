//
//  SearchViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 3/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

//view controller used in the search tab

import Foundation
import UIKit

class SearchViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //@IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let API = TVDBAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationName = Notification.Name("load")
        searchBar.delegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //tableView.register(self.tableView, forCellReuseIdentifier: "cell")
        //tableView.separatorStyle = .none
        tableView.rowHeight = 75

        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: notificationName, object: nil)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showNamesFromSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        
        //let detailItem = x.description[indexPath.row]
        cell.textLabel?.text = showNamesFromSearch[indexPath.item]
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.lineBreakMode = .byTruncatingTail
        
        cell.detailTextLabel?.text = showDescFromSearch[indexPath.item]
        cell.detailTextLabel?.numberOfLines = 3
        cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let showSearched: String?
        
        if searchBar.text != nil{
            showSearched = searchBar.text!
            showNamesFromSearch.removeAll()
            showDescFromSearch.removeAll()
            API.searchShows(show: showSearched!)
        }

        self.searchBar.endEditing(true)
        
    }
    func loadList(notification: NSNotification){
        //load data here
        print("reloading data")
        self.tableView.reloadData()
    }
}
