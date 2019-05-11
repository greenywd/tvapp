//
//  Show.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 20/4/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

struct ShowJSON : Codable {
    var Error: String?
    let data: Data?
    
    struct Data : Codable {
        let id: Int
        let overview: String
        let seriesName: String
    }
}

struct Series {
    struct Season {
        let number: Int
        var episodes: [Episode]
    }
    
    struct Episode {
        let name: String
        let season: Int
        let episode: Int
        let overview: String?
        let id: Int
    }
}
