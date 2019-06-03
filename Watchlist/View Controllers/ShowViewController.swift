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

class ShowViewController: UITableViewController, UITextViewDelegate {
    
    //MARK: Properties
    
    // var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImage: UIImageView?
    @IBOutlet weak var bannerImageCell: UITableViewCell!
    @IBOutlet weak var showDescription: UITextView!
    
    var show: Show!
    var rightBarButtonItem: UIBarButtonItem?
    
    //MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        showDescription.text = show.overview
        showDescription.textContainer.maximumNumberOfLines = 7
        
        //activityIndicator?.hidesWhenStopped = true
        //activityIndicator?.startAnimating()
        
        // navigationItem.title = searchShow.seriesName ?? currentShow.seriesName
        TVDBAPI.getShow(id: show!.id, completion: {(showData) in
            if let show = showData {
                // TODO: Implement properties from this (ratings, network, etc)
                self.show = show
            }
        })
        
        TVDBAPI.getImages(show: show.id, resolution: .FHD, completion: { (images) in
            if let url = images?.data?.first?.fileName {
                let url = URL(string: "https://www.thetvdb.com/banners/" + url)
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    
                    DispatchQueue.main.async {
                        if let image = data {
                            let banner = UIImage(data: image)
                            self.bannerImage?.image = banner
                            
                            let ratio = banner!.size.width / banner!.size.height
                            if self.bannerImageCell.frame.width > self.bannerImageCell.frame.height {
                                let newHeight = self.bannerImageCell.frame.width / ratio
                                self.bannerImage?.frame.size = CGSize(width: self.bannerImageCell.frame.width, height: newHeight)
                            }
                            
                            self.bannerImageCell.layoutIfNeeded()
                            
                        }
                        //self.activityIndicator?.stopAnimating()
                    }
                }
            }        
        })
        
        navigationItem.title = show.seriesName
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (PersistenceService.entityExists(id: show!.id)) {
            rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star Highlighted"), style: .plain, target: self, action: #selector(removeShow))
        } else {
            rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Star"), style: .plain, target: self, action: #selector(favouriteShow))
        }
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func favouriteShow() {
        let favShow = CD_Show(context: PersistenceService.context)
        favShow.id = Int32(show.id)
        favShow.seriesName = show.seriesName
        favShow.overview = show.overview
        favShow.bannerImage = bannerImage?.image?.pngData()
        
        PersistenceService.saveContext()
        rightBarButtonItem?.image = UIImage(named: "Star Highlighted")
        rightBarButtonItem?.action = #selector(removeShow)
    }
    
    @objc func removeShow() {
        PersistenceService.deleteEntity(id: show.id)
        rightBarButtonItem?.image = UIImage(named: "Star")
        rightBarButtonItem?.action = #selector(favouriteShow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let episodeVC as ShowEpisodeViewController:
            if (segue.identifier == "segueToEpisode") {
                episodeVC.id = show.id
            }
            
        case let seasonsVC as ShowSeasonsTableViewController:
            if (segue.identifier == "showToSeasonEpisode") {
                seasonsVC.showID = show.id
            }
            
        default:
            preconditionFailure("Expected a ShowEpisodeViewController or ShowSeasonsTableViewController")
        }
    }
}

extension ShowViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue performed in Storyboard
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print(indexPath, indexPath.row)
        if indexPath.row == 0 {
            print("Resizing Image...")
            // Assuming all images are 16:9
            return self.view.bounds.width * 0.5625
        }
        return UITableView.automaticDimension
    }
}
