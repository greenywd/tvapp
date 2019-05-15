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
import CoreData

class HomeViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	var favouriteShows = [FavouriteShows]()
    
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
        
        let fetchRequest: NSFetchRequest<FavouriteShows> = FavouriteShows.fetchRequest()
        do {
            let shows = try PersistenceService.context.fetch(fetchRequest)
            self.favouriteShows = shows
            print("Updated favourite show list.")
        } catch {
            print(error, error.localizedDescription)
        }
        
		tableView.reloadData()
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: animated)
		super.viewWillDisappear(animated)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle{
		return .lightContent
	}
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favouriteShows.isEmpty {
            return 1
        }
        
        return favouriteShows.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "favouriteShowsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        if (favouriteShows.isEmpty) {
            cell.textLabel?.text = "No Favourites!"
            cell.detailTextLabel?.text = "Head to the search tab to find some shows!"
        } else {
            cell.textLabel?.text = favouriteShows[indexPath.row].title
            cell.detailTextLabel?.text = favouriteShows[indexPath.row].overview
        }
        
        return cell
    }
}
