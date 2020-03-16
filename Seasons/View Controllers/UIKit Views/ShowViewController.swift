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
    
    var showTM: TMShow!
    
    var rightBarButtonItem = UIBarButtonItem()
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = show.seriesName
        showDescription.text = show.overview
        showDescription.textContainer.lineBreakMode = .byTruncatingTail
        showMoreButton.addTarget(self, action: #selector(expandTextView), for: .touchUpInside)
        
        let dispatchGroup = DispatchGroup()
        
        if (!PersistenceService.showExists(id: show!.id)) {
            setupRightBarButtonItem(isBusy: true)
            dispatchGroup.enter()
            TVDBAPI.getShow(id: show!.id) { (showData) in
                if let show = showData {
                    self.show = show
                }
            }
            var preferredResolution: TVDBAPI.Resolution {
                if UserDefaults.standard.bool(forKey: "preferFullHD") {
                    return .FHD
                }
                return .HD
            }
            
            TVDBAPI.getImageURLs(show: show.id, resolution: preferredResolution) { (images) in
                if let url = images?.data?.first?.fileName {
                    let url = URL(string: "https://www.thetvdb.com/banners/" + url)
                    DispatchQueue.global(qos: .userInteractive).async {
                        do {
                            let data = try Data(contentsOf: url!)
                            let header = UIImage(data: data)
                            
                            DispatchQueue.main.async {
                                self.show.header = url?.absoluteString
                                self.headerImageView?.image = header
                                dispatchGroup.leave()
                            }
                            
                        } catch {
                            os_log("Failed to retrieve data at %@ with %@.", log: .networking, type: .error, url!.absoluteString, error.localizedDescription)
                        }
                    }
                } else {
                    os_log("Didn't find any %@ posters, trying %@.", log: .ui, type: .info, preferredResolution.rawValue, preferredResolution.reversed().rawValue)
                    TVDBAPI.getImageURLs(show: self.show.id, resolution: preferredResolution.reversed()) { (images) in
                        if let url = images?.data?.first?.fileName {
                            let url = URL(string: "https://www.thetvdb.com/banners/" + url)
                            DispatchQueue.global(qos: .userInteractive).async {
                                do {
                                    let data = try Data(contentsOf: url!)
                                    let header = UIImage(data: data)
                                    
                                    DispatchQueue.main.async {
                                        self.show.header = url?.absoluteString
                                        self.headerImageView?.image = header
                                        dispatchGroup.leave()
                                    }
                                    
                                } catch {
                                    os_log("Failed to retrieve data at %@ with %@.", log: .networking, type: .error, url!.absoluteString, error.localizedDescription)
                                }
                            }
                        } else {
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        } else {
            
            let id = show!.id
            
            if let show = PersistenceService.getShow(id: id) {
                self.show = show
                
                if let headerImage = show.headerImage, let header = UIImage(data: headerImage) {
                    headerImageView?.image = header
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.setupRightBarButtonItem(isBusy: false)
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
        let headerImage = self.headerImageView?.image?.pngData()
        
        DispatchQueue.global(qos: .userInteractive).async {
            let favShow = CD_Show(context: PersistenceService.context)
            favShow.id = Int32(self.show.id)
            favShow.seriesName = self.show.seriesName
            favShow.overview = self.show.overview
            favShow.headerImage = headerImage
            favShow.header = self.show.header
            favShow.banner = self.show.banner
            favShow.network = self.show.network
            favShow.runtime = self.show.runtime
            favShow.siteRating = self.show.siteRating ?? 0
            favShow.siteRatingCount = self.show.siteRatingCount ?? 0
            favShow.status = self.show.status
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            
            DispatchQueue.global(qos: .userInitiated).async {
                let bannerURL = URL(string: "https://artworks.thetvdb.com/banners/" + self.show.banner!)
                let bannerImage = try? Data(contentsOf: bannerURL!)
                
                if let banner = bannerImage, let image = UIImage(data: banner) {
                    favShow.bannerImage = image.pngData()
                }
            }
            
            TVDBAPI.getEpisodes(show: self.show.id) { (episodeList) in
                if let episodes = episodeList {
                    for episode in episodes {
                        let cdEpisode = CD_Episode(context: PersistenceService.context)
                        cdEpisode.episodeName = episode.episodeName
                        cdEpisode.airedEpisodeNumber = episode.airedEpisodeNumber!
                        cdEpisode.airedSeason = episode.airedSeason!
                        cdEpisode.filename = episode.filename
                        cdEpisode.firstAired = episode.firstAired
                        cdEpisode.id = episode.id
                        cdEpisode.overview = episode.overview
                        cdEpisode.seriesId = episode.seriesId!
                        // cdEpisode.image = try? Data(contentsOf: URL(string: "https://artworks.thetvdb.com/banners/" + episode.filename!)!)
                        favShow.addToEpisode(cdEpisode)
                    }
                }
                
                if (favShow.bannerImage != nil) {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                PersistenceService.saveContext()
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
