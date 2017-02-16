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
	enum ShowCategory {
		case Description
		
		func toString() -> String {
			switch self {
			case .Description:
				return "Description"
			}
		}
	}
	
	let category: ShowCategory
	let summary: String
}
