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
import os

class ShowViewController: UITableViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var headerImageView: SeasonsHeaderImageView?
    @IBOutlet weak var showDescription: UITextView!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet var showDescriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showDescriptionBottomConstraint: NSLayoutConstraint!
    
    var show: Show! {
        didSet {
            DispatchQueue.main.async {
                if (self.showDescription.frame.height < 150) {
                    
                    if let btn = self.showMoreButton {
                        btn.removeFromSuperview()
                        self.showDescriptionBottomConstraint.constant = 0
                    }
                    
                    self.showDescriptionHeightConstraint.isActive = false
                }
                self.tableView.reloadRows(at: [(IndexPath(row: 0, section: 0))], with: .none)
            }
        }
    }
    
    var rightBarButtonItem = UIBarButtonItem()
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = show.name
        showDescription.text = show.overview
        showDescription.textContainer.lineBreakMode = .byTruncatingTail
        showMoreButton.addTarget(self, action: #selector(expandTextView), for: .touchUpInside)
        
        let dispatchGroup = DispatchGroup()
        
        if (!PersistenceService.showExists(id: show!.id)) {
            setupRightBarButtonItem(isBusy: true)
            dispatchGroup.enter()
            TMDBAPI.getShow(id: show!.id) { (showData) in
                if let show = showData {
                    self.show = show
                    
                    if let backdrop = self.show.backdropImage, let image = UIImage(data: backdrop) {
                        self.show.backdropImage = image.jpegData(compressionQuality: 0.85)
                    } else {
                        DispatchQueue.global(qos: .userInitiated).async {
                            let bannerURL = URL(string: "https://image.tmdb.org/t/p/original" + self.show.backdropPath!)
                            let bannerImage = try? Data(contentsOf: bannerURL!)
                            DispatchQueue.main.async {
                                self.headerImageView!.image = UIImage(data: bannerImage!)
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
        } else {
            
            let id = show!.id
            
            if let show = PersistenceService.getShow(id: id) {
                self.show = show
                
                if let headerImage = show.backdropImage, let header = UIImage(data: headerImage) {
                    headerImageView?.image = header
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.setupRightBarButtonItem(isBusy: false)
            self.tableView.reloadData()
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layoutMargins = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // setupRightBarButtonItem(isBusy: false)
    }
    
    @objc func expandTextView() {
        if (showDescriptionHeightConstraint.isActive) {
            showDescriptionHeightConstraint.isActive = false
            showMoreButton.removeFromSuperview()
            self.showDescriptionBottomConstraint.constant = 0
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    func setupRightBarButtonItem(isBusy: Bool) {
        if (isBusy) {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = .systemOrange
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicator)
            return
        } else {
            if (PersistenceService.showExists(id: show!.id)) {
                rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(removeShow))
            } else {
                rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(favouriteShow))
            }
        }
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func favouriteShow() {
        // There's a better way to do this, right?
        
        setupRightBarButtonItem(isBusy: true)
        // Workaround for accessing UI from background thread
        let headerImage = self.headerImageView?.image?.jpegData(compressionQuality: 0.85)
        self.show.backdropImage = headerImage
        DispatchQueue.global(qos: .userInteractive).async {

            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            for season in self.show.seasons as! Set<Season> {
                TMDBAPI.getEpisodes(show: self.show.id, season: season.seasonNumber) { (episodes) in
                    if let episodes = episodes {
                        season.addToEpisodes(NSSet(array: episodes))
                        
                        if season.seasonNumber == self.show.numberOfSeasons {
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                do {
                    try PersistenceService.temporaryContext.save()
                    try PersistenceService.context.save()
                } catch {
                    os_log("Failed to save context temporaryContext with %@", log: .networking, type: .error, error.localizedDescription)
                }
                self.setupRightBarButtonItem(isBusy: false)
                self.rightBarButtonItem.image = UIImage(systemName: "star.fill")
                self.rightBarButtonItem.action = #selector(self.removeShow)
            }
        }
    }
    
    @objc func removeShow() {
        PersistenceService.deleteShow(id: show.id)
        rightBarButtonItem.image = UIImage(systemName: "star")
        rightBarButtonItem.action = #selector(favouriteShow)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let episodeVC as ShowEpisodeViewController:
            if (segue.identifier == "segueToEpisode") {
                episodeVC.showID = show.id
            }
            
        case let seasonsVC as ShowSeasonsTableViewController:
            if (segue.identifier == "showToSeasonEpisode") {
                seasonsVC.showID = show.id
                seasonsVC.seasons = show.seasons?.allObjects as? [Season]
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
}
