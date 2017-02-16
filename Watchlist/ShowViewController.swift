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
	
    //@IBOutlet var showScrollView: UIScrollView?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImage: UIImageView?
    @IBOutlet var descriptionOfShow: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    @IBOutlet weak var barItem: UITabBar!
	@IBOutlet weak var tableView: UITableView!
    
    let API = TVDBAPI()
	var itemsForCells: [ShowItem] = []
	
	//MARK: Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.action))
		
		//self.activityIndicator?.hidesWhenStopped = true
		self.activityIndicator?.startAnimating()
		
		DispatchQueue.global().async {

			print("\(self): \(cellTappedForShowID)")
			self.API.getDetailsOfShow(id: cellTappedForShowID, callback: { data, artworkURL, error in
				guard let data = data else {
					print("ERROR: \(error ?? "error not found" as! Error)")
					return
				}
				print("Data: \(data)")
				
				//TODO: add ui stuff here
				self.navigationItem.title = detailsForController["name"] as? String
				//self.descriptionOfShow?.text = detailsForController["description"] as? String
				
				self.itemsForCells.append(ShowItem(category: .Description, summary: (detailsForController["description"] as? String)!))
				print("ITEMS FOR CELLS \(self.itemsForCells.count)")
				self.tableView.reloadData()
				
				self.navigationItem.rightBarButtonItem = rightBarButtonItem
				
				print("WAT2HEK: \(artworkURL!)")
				
				//FIXME: throwin nil
				let dataForImage = try? Data(contentsOf: URL(string: artworkURL!)!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
				// THE URL IS BAD (only showing relative url, need to add everything else
				
				DispatchQueue.main.async {
					self.bannerImage?.image = UIImage(data: dataForImage!)
					print("WAT2HEK")
				}
				
				
				self.activityIndicator?.stopAnimating()
			})
		}
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = 90
		tableView.layoutMargins = .zero
		tableView.separatorInset = .zero
		tableView.separatorStyle = .none
		
    }
	
	func action(){
		print("TAPPED")
		let showName = detailsForController["name"] as? String
		
		if favouriteShows[showName!] == nil {
			favouriteShows[showName!] = cellTappedForShowID
			userDefaults.set(showName, forKey: "favouriteShowTitles")
			print(userDefaults.value(forKey: "favouriteShowTitles")!)
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemsForCells.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let item = itemsForCells[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShowTableViewCell
		cell.showItem = item
		print("meme \(cell.showItem?.summary ?? "No summary found.")")
		
		return cell
	}

}
