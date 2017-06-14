//
//  ShowViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 13/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

//view controller used to display details of shows

import Foundation
import UIKit

var detailsForController = detailsOfShow

class ShowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//MARK: Properties
	
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImage: UIImageView? = nil
	@IBOutlet var tableView: UITableView!
    
    let API = TVDBAPI()
	var itemsForCells: [ShowItem] = []
	var show = Show()
	var prefs = [String: Int]()
	var rightBarButtonItem: UIBarButtonItem = UIBarButtonItem()
	
	//MARK: Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.activityIndicator?.hidesWhenStopped = true
		self.activityIndicator?.startAnimating()
		
		if userDefaults.value(forKey: "favouriteShows") != nil {
			prefs = userDefaults.value(forKey: "favouriteShows") as! [String: Int]
			print("prefs", prefs)
		}
		
		self.activityIndicator?.startAnimating()
		
		DispatchQueue.global(qos: .background).async {
			
			self.API.getDetailsOfShow(id: cellTappedForShowID, callback: { data, artworkURL, error in
				guard data != nil else {
					print("ERROR: \(error ?? "error not found" as! Error)")
					return
				}
				
				if self.prefs.keys.contains((detailsForController["name"] as? String)!){
					self.rightBarButtonItem = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(self.action))
					print("dank", detailsForController["name"] as? String ?? "f")
				} else {
					self.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.action))
					print("memes", detailsForController["name"] as? String ?? "f")
				}
				
				DispatchQueue.main.async {
					
					if self.navigationItem.title != nil {
						self.navigationItem.title = detailsForController["name"] as? String
					}
					self.itemsForCells.append(ShowItem(category: .Description, summary: (detailsForController["description"] as? String)!))
					self.itemsForCells.append(ShowItem(category: .Episodes, summary: nil))

					self.tableView.reloadData()

					self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
				}

				
				if let url = showArtworkURL?.absoluteString {
					let dataForImage = try? Data(contentsOf: URL(string: url)!)
					
					DispatchQueue.main.async {
						self.bannerImage?.image = UIImage(data: dataForImage!)
					}
				}
				
				self.activityIndicator?.stopAnimating()
			})
		}
		
		tableView.dataSource = self
		tableView.delegate = self
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 200
		
		tableView.layoutMargins = .zero
		tableView.separatorInset = .zero
		tableView.separatorStyle = .none
		
    }
	
	func action(){
		
		if let favShows = userDefaults.value(forKey: "favouriteShows") as? [String: Int] {
			favouriteShows = favShows
			//print("Favourite Shows: ", favouriteShows)
		}
		
		if favouriteShows.keys.contains(self.navigationItem.title!) == false{
			favouriteShows[self.navigationItem.title!] = detailsForController["id"] as? Int
			self.rightBarButtonItem.title = "Remove"
		} else {
			favouriteShows.removeValue(forKey: self.navigationItem.title!)
			self.rightBarButtonItem.title = "Add"
		}
		
		userDefaults.set(favouriteShows, forKey: "favouriteShows")

	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemsForCells.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let item = itemsForCells[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowTableViewCell
		cell.showItem = item
		
		if indexPath.row == 1 {
			cell.isUserInteractionEnabled = true
			cell.accessoryType = .disclosureIndicator
		}

		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 1 {
			performSegue(withIdentifier: "segueToEpisode", sender: self)
		}
	}

}
