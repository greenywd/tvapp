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

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	var favouriteShowsForTableView = [String]()
	var favouriteShowIDs = [Int]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true        
        API.retrieveToken()
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = 90
		tableView.layoutMargins = .zero
		tableView.separatorInset = .zero
		tableView.separatorStyle = .none
	
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
		super.viewWillAppear(animated)
		
		favouriteShowsForTableView.removeAll()
		favouriteShowIDs.removeAll()
		
		if userDefaults.value(forKey: "favouriteShows") != nil {
			
			favouriteShows = userDefaults.value(forKey: "favouriteShows") as! [String: Int]
			print("favourite shows", favouriteShows)
			
			let sortedFavouriteShows = favouriteShows.sorted(by: <)
			print("sorted: ", sortedFavouriteShows)
			
			let _ = sortedFavouriteShows.map({
				if !(favouriteShowsForTableView.contains($0.key)){
					favouriteShowsForTableView.append($0.key)
				}
				if !(favouriteShowIDs.contains($0.value)){
					favouriteShowIDs.append($0.value)
				}
			})
		}
		
		tableView.reloadData()
		
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if favouriteShowsForTableView.isEmpty {
			return 1
		}
		
		return favouriteShowsForTableView.count
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if !favouriteShowIDs.isEmpty {
			cellTappedForShowID	= Array(favouriteShowIDs)[indexPath.row]
			performSegue(withIdentifier: "segue", sender: self)
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cellIdentifier = "favouriteShowsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellIdentifier)
		
		cell.textLabel?.textColor = UIColor.white
		cell.detailTextLabel?.textColor = UIColor.white
		
		if favouriteShowsForTableView.isEmpty == false {
			cell.textLabel?.text = favouriteShowsForTableView[indexPath.row]
			cell.detailTextLabel?.text = favouriteShowIDs[indexPath.row].description
		} else {
			cell.textLabel?.text = "No Favourites!"
			cell.detailTextLabel?.text = "Head to the search tab to find some shows!"
		}
		
		return cell
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle{
		return .lightContent
	}
}
