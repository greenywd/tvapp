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
	var favouriteShowsForTableView: [String]?
	var favouriteShowIDs: [Int]?
	
	//var detailShow = [Show]()
	
	override func awakeFromNib() {
		
		favouriteShows = userDefaults.value(forKey: "favouriteShows") as! [String: Int]
		let _ = favouriteShows.map({ favouriteShowsForTableView?.append($0.key) })
		
		print(favouriteShowsForTableView ?? "oops")
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
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
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}
	
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (favouriteShowsForTableView?.isEmpty)! {
			return 1
		}
		
		return (favouriteShowsForTableView?.count)!
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		cellTappedForShowID	= Array(favouriteShows.values)[indexPath.row]
		performSegue(withIdentifier: "segue", sender: self)
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cellIdentifier = "favouriteShowsCell"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
	
		if favouriteShowsForTableView?.isEmpty == false {
			cell.textLabel?.text = favouriteShowsForTableView?[indexPath.row]
			cell.textLabel?.textColor = UIColor.white
		}
		
		return cell
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle{
		return .lightContent
	}
}
