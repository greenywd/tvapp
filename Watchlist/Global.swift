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
let API = TVDBAPI()

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

struct Show {
	var title: String
	var id: Int
	var description: String
	
	init (title: String = "Unknown Title", id: Int = 000000, description: String = "No Description") {
		self.title = title
		self.id = id
		self.description = description
	}
}

struct SearchResults : Codable {
    let data: [Data]?
    
    struct Data : Codable {
        let aliases: [String]
        let banner: String
        let firstAired: String
        let id: Int
        let network: String
        let overview: String?
        let seriesName: String
        let status: String
    }
}
