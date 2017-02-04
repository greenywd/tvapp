//
//  Global.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 29/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation



let userDefaults = UserDefaults.standard

var tokenForAPI: String? = nil
var seriesName: JSON? = nil

var favouriteShows = [String: Int]()
var showNamesFromSearch = [String]()
var showDescFromSearch = [String]()

struct SearchingShows {
    var title: [String]
    var id: [String]!
    var description: [String]!
    
    init (titles: [String], ids: [String], descriptions: [String]) {
        self.title = titles
        self.id = ids
        self.description = descriptions
    }
}

