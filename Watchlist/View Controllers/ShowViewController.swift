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
    
    var showFromSearch: SearchResults.Data!
	var rightBarButtonItem: UIBarButtonItem = UIBarButtonItem()
    
	//MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
		activityIndicator?.hidesWhenStopped = true
        activityIndicator?.startAnimating()
        
        navigationItem.title = showFromSearch.seriesName
        
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

        print(segue.identifier, segue.destination)
        switch segue.destination {
        case let episodeVC as ShowEpisodeViewController:

            if (segue.identifier == "segueToEpisode") {
                print(showFromSearch.id)
                episodeVC.id = showFromSearch.id
            }
            
        case let descriptionVC as ShowDescriptionViewController:
            if (segue.identifier == "segueDescription") {
                descriptionVC.showDescriptionString = showFromSearch.overview
            }
            
        default:
            preconditionFailure("Expected a ShowEpisodeViewController or ShowDescriptionViewController")
        }
    }
}

extension ShowViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // Description and Episode - will add Actors later
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTableViewCell", for: indexPath) as! ShowTableViewCell

        switch indexPath.row {
        case 0:
            cell.type = .Description
            cell.showDescription = showFromSearch.overview
        case 1:
            cell.type = .Episodes
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue performed in Storyboard
        
        if (indexPath.row == 0) {
            performSegue(withIdentifier: "segueDescription", sender: self)
        } else if (indexPath.row == 1) {
            performSegue(withIdentifier: "segueToEpisode", sender: self)
        }
    }
}
