//
//  Global.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 29/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

#warning ("TODO: Remove this file")

import Foundation
import UIKit

let userDefaults = UserDefaults.standard

var favouriteShows = [String: Int]()
var showNamesFromSearch = [String]()
var showDescFromSearch = [String]()
var showIDFromSearch = [Int]()

var showArtworkURL: URL?

let detailsOfShow = [
	
	"name" : String(),
	"description" : String(),
	"id" : Int(),
	"banner" : String(),
	"runtime" : String(),
	"network" : String(),
	"genre" : [String](),
	"airDay" : String(),
	"airTime" : String(),
	"tvRating" : String(),
	"userRating" : String()
	
] as [String : Any]
