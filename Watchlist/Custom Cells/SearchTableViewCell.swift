//
//  SearchTableViewCell.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 11/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    var show: Show?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        titleLabel.textColor = UIColor.white
//        detailLabel.textColor = UIColor.white
//        
//        if let show = show {
//            titleLabel.text = show.seriesName
//            detailLabel.text = show.overview
//            
//            if let url = URL(string: "https://www.thetvdb.com/banners/" + show.banner!) {
//                
//                if backgroundImage.image == nil {
//                    DispatchQueue.global(qos: .background).async {
//                        let dataForImage = try? Data(contentsOf: url)
//                        
//                        DispatchQueue.main.async {
//                            if let image = dataForImage {
//                                self.backgroundImage.image = UIImage(data: image)
//                            }
//                        }
//                    }
//                }
//            }
//            
//            // visualEffectView.effect = UIBlurEffect(style: .dark)
//        }
    }
    
    func removeImage() {
        backgroundImage.image = nil
    }
}
