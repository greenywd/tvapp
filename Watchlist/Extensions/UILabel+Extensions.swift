//
//  UILabel+Extensions.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 14/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    var maxNumberOfLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font!], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}
