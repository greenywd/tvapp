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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // visualEffectView.effect = UIBlurEffect(style: .dark)
    }
}
