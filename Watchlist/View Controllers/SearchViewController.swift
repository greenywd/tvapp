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
import Alamofire

class SearchViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let notificationName = Notification.Name("load")
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
		
		//so we can still tap on the tableview
		tap.cancelsTouchesInView = false
		
		view.addGestureRecognizer(tap)
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = 90
		tableView.layoutMargins = .zero
		tableView.separatorInset = .zero
		tableView.separatorStyle = .none
		searchBar.delegate = self
		
		
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
			cell.textLabel?.textColor = UIColor.white
		}
		
		if showDescFromSearch.isEmpty == false {
			cell.detailTextLabel?.text = showDescFromSearch[indexPath.row]
			cell.detailTextLabel?.numberOfLines = 3
			cell.detailTextLabel?.lineBreakMode = .byTruncatingTail
			cell.detailTextLabel?.textColor	= UIColor.white
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		cellTappedForShowID = showIDFromSearch[indexPath.row]
		print("cell tapped \(cellTappedForShowID)")
		print(showIDFromSearch[indexPath.row])
		
		performSegue(withIdentifier: "segue", sender: self)
		print("row: \(indexPath.row)")
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
		self.tableView.reloadData()
		self.activityIndicator.startAnimating()
	}
	
	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
		searchBar.keyboardAppearance = .dark
		return true
	}
	
	func loadList(notification: NSNotification){
		print("reloading data")
		self.tableView.separatorStyle = .singleLine
		self.tableView.reloadData()
		self.activityIndicator.stopAnimating()
	}
	
/*    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
			if let showVC = segue.destination as? ShowViewController {
				// Assign the selected title to communityName
				showVC.navigationItem.title = "test"
			}
        }
    }
*/
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
