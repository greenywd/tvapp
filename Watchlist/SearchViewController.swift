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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationName = Notification.Name("load")
        searchBar.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        
        //so we can still tap on the tableview
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 75
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: notificationName, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showNamesFromSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        
        if showNamesFromSearch.isEmpty == false {
            cell.textLabel?.text = showNamesFromSearch[indexPath.row]
            cell.textLabel?.numberOfLines = 1
            cell.textLabel?.lineBreakMode = .byTruncatingTail
			cell.textLabel?.textColor = UIColor.lightGray
        }
        
        if showDescFromSearch.isEmpty == false {
            cell.detailTextLabel?.text = showDescFromSearch[indexPath.row]
            cell.detailTextLabel?.numberOfLines = 3
            cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
			cell.detailTextLabel?.textColor	= UIColor.lightGray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "segue", sender: self)
        print(indexPath.row)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text != nil{
            showNamesFromSearch.removeAll()
            showDescFromSearch.removeAll()
            showIDFromSearch.removeAll()
            
            let API = TVDBAPI()
            API.searchShows(show: searchBar.text!)
        }
        self.searchBar.endEditing(true)
    }
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		searchBar.keyboardAppearance = .dark
		return true
	}
    
    func loadList(notification: NSNotification){
        print("reloading data")
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            // Setup new view controller
        }
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
