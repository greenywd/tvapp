//
//  ShowEpisodeViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 18/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowEpisodeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	let API = TVDBAPI()
	var seasonEpisode = [String]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let notificationName = Notification.Name("reloadEpisodes")

		DispatchQueue.global().async {
			// Get episodes
			self.API.getEpisodesForShow(id: cellTappedForShowID, callback: { seasons, error in
				if ((error) != nil) {print(error!); return}
				for season in seasons! {
					print(season.number)
					for episode in season.episodes {
						if episode.episode < 10 {
							print("S0\(episode.season)E0\(episode.episode)")
							self.seasonEpisode.append("S0\(episode.season)E0\(episode.episode) - \(episode.name)")
						} else {
							print("S0\(episode.season)E\(episode.episode)")
							self.seasonEpisode.append("S0\(episode.season)E\(episode.episode) - \(episode.name)")
						}
						print(self.seasonEpisode)
						
					}
				}
			})
		}

		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = 90
		tableView.layoutMargins = .zero
		tableView.separatorInset = .zero
		tableView.separatorStyle = .none
		tableView.reloadData()
		
        // Do any additional setup after loading the view.
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: notificationName, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return seasonEpisode.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cellIdentifier = "cell"
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
		
		if seasonEpisode.isEmpty == false {
			cell.textLabel?.text = seasonEpisode[indexPath.row]
			cell.textLabel?.numberOfLines = 1
		}
		
		return cell
	}
	
	func loadList(notification: NSNotification){
		print("reloading data")
		self.tableView.separatorStyle = .singleLine
		self.tableView.reloadData()
		//self.activityIndicator.stopAnimating()
	}
}
