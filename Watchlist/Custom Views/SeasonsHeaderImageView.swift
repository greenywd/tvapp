//
//  SeasonsHeaderImageView.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 21/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

class SeasonsHeaderImageView : UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resize()
    }
    
    private func resize() {
        let ratio: CGFloat = 0.5625
        let currentFrame = self.bounds
        
        self.frame = CGRect(x: 0, y: 0, width: currentFrame.width, height: currentFrame.width * ratio)
    }
}
