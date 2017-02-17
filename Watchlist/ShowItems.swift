//
//  ShowItems.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 16/2/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

struct ShowItem {
	
	let category: ShowCategory
	let summary: String?
	
	enum ShowCategory {
		case Description
		case Episodes
		func toString() -> String {
			switch self {
			case .Description:
				return "Description"
			case .Episodes:
				return "Episodes"
			
			}
		}
	}
}
