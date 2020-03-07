//
//  UIUserInterfaceStyle+Extensions.swift
//  Seasons
//
//  Created by Thomas Greenwood on 6/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

extension UIUserInterfaceStyle {
    var description : String {
        switch self {
        // Use Internationalization, as appropriate.
        case .unspecified: return "Unspecified/Auto"
        case .dark: return "Dark"
        case .light: return "Light"
        @unknown default:
            return "Unknown"
        }
    }
}
