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

class ShowViewController: UITableViewController {
    
    //MARK: - Properties
    
    // var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImageView: SeasonsHeaderImageView?
    @IBOutlet weak var bannerImageCell: UITableViewCell!
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

        // print(showDescriptionHeightConstraint.constant)
        navigationItem.title = show.seriesName
        showDescription.text = show.overview
        showDescription.textContainer.lineBreakMode = .byTruncatingTail
        showMoreButton.addTarget(self, action: #selector(expandTextView), for: .touchUpInside)
        
        let dispatchGroup = DispatchGroup()
        
        if (!PersistenceService.entityExists(id: show!.id)) {
            setupRightBarButtonItem(isBusy: true)
            dispatchGroup.enter()
            TVDBAPI.getShow(id: show!.id) { (showData) in
                if let show = showData {
                    self.show = show
                }
            }
            
            TVDBAPI.getImageURLs(show: show.id, resolution: .HD) { (images) in
                if let url = images?.data?.first?.fileName {
                    let url = URL(string: "https://www.thetvdb.com/banners/" + url)
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url!)
                        
                        DispatchQueue.main.async {
                            if let image = data {
                                let banner = UIImage(data: image)
                                self.bannerImageView?.image = banner
                                dispatchGroup.leave()
                            }
                        }
                    }
                }
            }
        } else {
            let id = show!.id
            let show2 = PersistenceService.getShow(id: id)
            
            if let show = show2 {
                self.show = show
                
                if let bannerImage = show.bannerImage, let banner = UIImage(data: bannerImage) {
                    bannerImageView?.image = banner
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.setupRightBarButtonItem(isBusy: false)
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layoutMargins = .zero
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
            if (PersistenceService.entityExists(id: show!.id)) {
                rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(removeShow))
            } else {
                rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(favouriteShow))
            }
        }
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func favouriteShow() {
        let favShow = CD_Show(context: PersistenceService.context)
        favShow.id = Int32(show.id)
        favShow.seriesName = show.seriesName
        favShow.overview = show.overview
        favShow.bannerImage = bannerImageView?.image?.pngData()
        
        PersistenceService.saveContext()
        rightBarButtonItem.image = UIImage(systemName: "star.fill")
        rightBarButtonItem.action = #selector(removeShow)
    }
    
    @objc func removeShow() {
        PersistenceService.deleteEntity(id: show.id)
        rightBarButtonItem.image = UIImage(systemName: "star")
        rightBarButtonItem.action = #selector(favouriteShow)
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
}
