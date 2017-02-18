//
//  Global.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 29/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

let userDefaults = UserDefaults.standard
var cellTappedForShowID = Int()

var tokenForAPI: String? = nil
var seriesName: JSON? = nil

var favouriteShows = [String: Int]()
var showNamesFromSearch = [String]()
var showDescFromSearch = [String]()
var showIDFromSearch = [Int]()

var showArtworkURL: URL?

let detailsOfShow = [
	
	"name" : String(),
	"description" : String(),
	"id" : String(),
	"banner" : String(),
	"runtime" : String(),
	"network" : String(),
	"genre" : [String](),
	"airDay" : String(),
	"airTime" : String(),
	"tvRating" : String(),
	"userRating" : String()
	
] as [String : Any]
