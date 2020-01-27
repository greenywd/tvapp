//
//  SearchTableViewCell.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 11/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowTableViewCell : UITableViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    var show: Show? { didSet { updateCell() } }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImageView.image = nil
        show = nil
    }
    
    func updateCell() {
        if let show = show {
            if (show.banner?.count == 0) {
                return
            }
            
            if let banner = show.bannerImage, let image = UIImage(data: banner) {
                backgroundImageView.image = image
            } else {
                if let bannerURL = show.banner {
                    let url = URL(string: "https://artworks.thetvdb.com" + bannerURL)!
                    
                    if backgroundImageView.image == nil {
                        print("CELL URL \(bannerURL)")
                        DispatchQueue.global(qos: .userInteractive).async {
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
}
