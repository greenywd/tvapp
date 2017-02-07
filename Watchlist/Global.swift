//
//  Global.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 29/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation



let userDefaults = UserDefaults.standard
var cellTappedForShowID = Int()

var tokenForAPI: String? = nil
var seriesName: JSON? = nil

var favouriteShows = [String: Int]()
var showNamesFromSearch = [String]()
var showDescFromSearch = [String]()
var showIDFromSearch = [Int]()

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

struct Show {
    var title: [String]
    var id: [String]!
    var description: [String]!
    
    init (titles: [String], ids: [String], descriptions: [String]) {
        self.title = titles
        self.id = ids
        self.description = descriptions
    }
}

