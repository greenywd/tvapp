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
        show = nil
    }
    
    func updateCell() {
        if let show = show {
            titleLabel.text = show.seriesName
            detailLabel.text = show.overview
            
            if (show.banner?.count == 0) {
                backgroundImageView.image = nil
                return
            }
            
            if let header = show.bannerImage, let image = UIImage(data: header) {
                backgroundImageView.image = image
            } else {
                if let url = URL(string: "https://www.thetvdb.com/banners/" + show.banner!) {
                    if backgroundImageView.image == nil {
                        DispatchQueue.global(qos: .background).async {
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
