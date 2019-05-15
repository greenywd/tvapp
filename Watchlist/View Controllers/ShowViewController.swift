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
import CoreData

class ShowViewController: UIViewController {
	
	//MARK: Properties
	
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImage: UIImageView?
    @IBOutlet var tableView: UITableView!
    
    var currentShow: SearchResults.Data!
    var rightBarButtonItem: UIBarButtonItem?
    
	//MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
		activityIndicator?.hidesWhenStopped = true
        activityIndicator?.startAnimating()
        
        navigationItem.title = currentShow.seriesName
        
        TVDBAPI.getImages(show: currentShow.id, resolution: .FHD, completion: { (images) in
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
        print(currentShow.id)
        if (PersistenceService.entityExists(id: currentShow.id)) {
            rightBarButtonItem = UIBarButtonItem(title: "Remove", style: .plain, target: self, action: #selector(removeShow))
        } else {
            rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(favouriteShow))
        }

        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
		
    }
    
    @objc func favouriteShow() {
        let favShow = FavouriteShows(context: PersistenceService.context)
        favShow.id = Int32(currentShow.id)
        favShow.title = currentShow.seriesName
        favShow.overview = currentShow.overview

        dump(favShow)
        PersistenceService.saveContext()
        rightBarButtonItem?.title = "Remove"
        rightBarButtonItem?.action = #selector(removeShow)
    }
    
    @objc func removeShow() {
        let fetchRequest: NSFetchRequest<FavouriteShows> = FavouriteShows.fetchRequest()
        do {
            let shows = try PersistenceService.context.fetch(fetchRequest)
            for show in shows {
                if show.id == currentShow.id {
                    dump(show)
                    PersistenceService.context.delete(show)
                    PersistenceService.saveContext()
                    rightBarButtonItem?.title = "Add"
                    rightBarButtonItem?.action = #selector(favouriteShow)
                }
            }
        } catch {
            print(error, error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.destination {
        case let episodeVC as ShowEpisodeViewController:
            if (segue.identifier == "segueToEpisode") {
                print(currentShow.id)
                episodeVC.id = currentShow.id
            }
            
        case let descriptionVC as ShowDescriptionViewController:
            if (segue.identifier == "segueDescription") {
                descriptionVC.showDescriptionString = currentShow.overview
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
            cell.showDescription = currentShow.overview
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
