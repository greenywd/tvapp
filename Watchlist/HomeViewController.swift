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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = 90
		tableView.layoutMargins = .zero
		tableView.separatorInset = .zero
		tableView.separatorStyle = .none
		
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cellIdentifier = "favouriteShowsCell"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
		

		/*favShowTitlesDict = userDefaults.value(forKey: "favouriteShowTitles") as! [String]
		if let favShows = userDefaults.value(forKey: "favouriteShowTitles"){
			var favShowsTitleArray = favShows as! [String]
			favShowsTitleArray = favShowsTitleArray.sorted(by: <)
			
			let item = favShowsTitleArray[indexPath.row]
			//let detailItem = x.description[indexPath.row]
			
			cell.textLabel?.text = item
			//cell.detailTextLabel?.text = detailItem
*/

		return cell
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle{
		return .lightContent
	}
}
