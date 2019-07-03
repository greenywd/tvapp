//
//  UITextView+Extensions.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 26/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    var numberOfLines: Int {
        return Int(self.contentSize.height / self.font!.lineHeight)
    }
}
