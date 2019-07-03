//
//  EpisodeTableViewController.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 27/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EpisodeTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    // var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var bannerImageView: SeasonsHeaderImageView?
    @IBOutlet weak var bannerImageCell: UITableViewCell!
    @IBOutlet weak var showDescription: UITextView!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet var showDescriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showDescriptionBottomConstraint: NSLayoutConstraint!
    
    var episode: Episode! {
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
    var headerImage: UIImage? {
        didSet {
            self.bannerImageView?.image = self.headerImage
        }
    }
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print(showDescriptionHeightConstraint.constant)
        navigationItem.title = episode.episodeName
        showDescription.text = episode.overview
        showDescription.textContainer.lineBreakMode = .byTruncatingTail
        showMoreButton.addTarget(self, action: #selector(expandTextView), for: .touchUpInside)
        
        if let image = headerImage {
            bannerImageView?.image = image
        } else {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: URL(string: "https://www.thetvdb.com/banners/" + self.episode.filename!)!)
                
                DispatchQueue.main.async {
                    if let image = data {
                        let banner = UIImage(data: image)
                        self.bannerImageView?.image = banner
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layoutMargins = .zero
        tableView.reloadData()
    }
    
    @objc func expandTextView() {
        if (showDescriptionHeightConstraint.isActive) {
            showDescriptionHeightConstraint.isActive = false
            showMoreButton.removeFromSuperview()
            self.showDescriptionBottomConstraint.constant = 0
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let episodeVC as ShowEpisodeViewController:
            if (segue.identifier == "segueToEpisode") {
                episodeVC.id = episode.id
            }
            
        case let seasonsVC as ShowSeasonsTableViewController:
            if (segue.identifier == "showToSeasonEpisode") {
                seasonsVC.showID = episode.id
            }
            
        default:
            preconditionFailure("Expected a ShowEpisodeViewController or ShowSeasonsTableViewController")
        }
    }
}

extension EpisodeTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue performed in Storyboard
    }
}
