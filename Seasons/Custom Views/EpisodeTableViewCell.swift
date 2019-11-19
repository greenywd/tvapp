//
//  EpisodeTableViewCell.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 27/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class EpisodeTableViewCell : UITableViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    var episode: Episode? { didSet { updateCell() } }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        episode = nil
    }
    
    func updateCell() {
        if let episode = episode {
            titleLabel.text = episode.episodeName
            detailLabel.text = episode.overview
            
            if (episode.filename?.count == 0) {
                backgroundImageView.image = nil
                return
            }
            
            if let imageData = episode.image {
                self.backgroundImageView.image = UIImage(data: imageData)
                return
            }
            
            if let url = URL(string: "https://www.thetvdb.com/banners/" + episode.filename!) {
                if backgroundImageView.image == nil {
                    DispatchQueue.global(qos: .utility).async {
                        let dataForImage = try? Data(contentsOf: url)
                        
                        DispatchQueue.main.async {
                            if let image = dataForImage {
                                self.backgroundImageView.image = UIImage(data: image)
                            }
                        }
                    }
                }
            }
        }
    }
}
