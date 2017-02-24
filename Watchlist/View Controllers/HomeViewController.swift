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
	var favouriteShowsForTableView: Array<String>?
	var favouriteShowIDs: Array<Int>?
	
	override func awakeFromNib() {
		
		if let x = userDefaults.value(forKey: "favouriteShows") {
			print(x)
			favouriteShows = userDefaults.value(forKey: "favouriteShows") as! [String: Int]
			favouriteShowsForTableView = Array(favouriteShows.keys)
		}

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
        return 1
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		cellTappedForShowID	= Array(favouriteShows.values)[indexPath.row]
		performSegue(withIdentifier: "segue", sender: self)
		print("row: \(indexPath.row)")
		print(Array(favouriteShows.values)[indexPath.row])
	}
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cellIdentifier = "favouriteShowsCell"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
	
		if favouriteShows.isEmpty == false {
			cell.textLabel?.text = favouriteShowsForTableView?[indexPath.row]
			cell.textLabel?.textColor = UIColor.white
		}
		
		return cell
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle{
		return .lightContent
	}
}
