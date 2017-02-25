//
//  ShowViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 13/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

//view controller used to display details of shows
//TODO: Fix aspect ratio of bannerImage - make sure it's 16:9 no matter device size

import Foundation
import UIKit

var detailsForController = detailsOfShow

class ShowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//MARK: Properties
	
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var bannerImage: UIImageView?
    @IBOutlet var descriptionOfShow: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet weak var barItem: UITabBar!
	@IBOutlet weak var tableView: UITableView!
    
    let API = TVDBAPI()
	var itemsForCells: [ShowItem] = []
	var show = Show()
	
	//MARK: Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.action))

		self.activityIndicator?.startAnimating()
		
		DispatchQueue.global().async {
			
			self.API.getDetailsOfShow(id: cellTappedForShowID, callback: { data, artworkURL, error in
				guard let data = data else {
					print("ERROR: \(error ?? "error not found" as! Error)")
					return
				}
				print("Data: \(data)")
				
				//TODO: add ui stuff here
				self.navigationItem.title = detailsForController["name"] as? String
				self.itemsForCells.append(ShowItem(category: .Description, summary: (detailsForController["description"] as? String)!))
				self.itemsForCells.append(ShowItem(category: .Episodes, summary: nil))
				print("ITEMS FOR CELLS \(self.itemsForCells.count)")
				self.tableView.reloadData()
				
				self.navigationItem.rightBarButtonItem = rightBarButtonItem
				
				let dataForImage = try? Data(contentsOf: URL(string: artworkURL!)!)
				
				DispatchQueue.main.async {
					self.bannerImage?.image = UIImage(data: dataForImage!)
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
		print("TAPPED")

		if let favShows = userDefaults.dictionary(forKey: "favouriteShows") as? [String: Int] {
			favouriteShows = favShows
			print("Favourite Shows: ", favouriteShows)
		}
		
		if favouriteShows.keys.contains(self.navigationItem.title!) == false{
			favouriteShows[self.navigationItem.title!] = detailsForController["id"] as? Int
			userDefaults.set(favouriteShows, forKey: "favouriteShows")
		}
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
