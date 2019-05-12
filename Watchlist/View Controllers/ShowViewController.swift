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

class ShowViewController: UIViewController {
	
	//MARK: Properties
	
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImage: UIImageView?
    @IBOutlet var tableView: UITableView!
    
	var itemsForCells: [ShowItem] = []
    var showFromSearch: SearchResults.Data!
	var rightBarButtonItem: UIBarButtonItem = UIBarButtonItem()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
	//MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
		activityIndicator?.hidesWhenStopped = true
        activityIndicator?.startAnimating()
        
        navigationItem.title = self.showFromSearch.seriesName
        itemsForCells.append(ShowItem(category: .Description, summary: self.showFromSearch.overview))
        itemsForCells.append(ShowItem(category: .Episodes, summary: nil))
        
        TVDBAPI.getImages(show: showFromSearch.id, resolution: .FHD, completion: { (images) in
            if let url = images?.data?.first?.fileName {
                let url = URL(string: "https://www.thetvdb.com/banners/" + url)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    
                    DispatchQueue.main.async {
                        if let image = data {
                            self.bannerImage?.image = UIImage(data: image)
                            self.activityIndicator?.stopAnimating()
                        }
                    }
                }
            }        
        })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
		
    }
	
    @objc func action(){
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing for segue \n\n\n")
        guard let episodeVC = segue.destination as? ShowEpisodeViewController
            else { preconditionFailure("Expected a ShowEpisodeViewController") }
        
        if (segue.identifier == "segueToEpisode") {
            print(showFromSearch.id)
            episodeVC.id = showFromSearch.id
        }
    }
}

extension ShowViewController : UITableViewDataSource, UITableViewDelegate {
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
        // Segue performed in Storyboard
    }
}
