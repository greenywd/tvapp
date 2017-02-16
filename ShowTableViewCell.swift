//
//  DescriptionTableViewCell.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 16/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit

class ShowTableViewCell: UITableViewCell {

	@IBOutlet weak var descriptionOfShow: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	
	var showItem: ShowItem? {
		didSet {
			if let item = showItem {
				descriptionLabel.text = item.category.toString()
				descriptionOfShow.text = item.summary
			}
			else {
				descriptionLabel.text = nil
				descriptionOfShow.text = nil
			}
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

