//
//  APITypes.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 12/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

// TODO: Update all types to match API. Documentation says most of these are optional.
struct Authentication : Codable {
    let token: String?
    fileprivate let Error: String?
}

struct Show : Codable {
    var Error: String?
    let data: Data?
    
    struct Data : Codable {
        let id: Int
        let overview: String
        let seriesName: String
    }
}

struct Episodes : Codable {
    let data: [Data]?
    
    struct Data : Codable {
        let airedEpisodeNumber: Int
        let overview: String?
        let guestStars: [String]
        let id: Int
        let imdbId: String
        let filename: String
        let director: String
        let airedSeason: Int
        // let siteRating: Double
        let episodeName: String
        // let writers: [String]
        // let directors: [String]
        let seriesId: Int
        let firstAired: String
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

struct Images : Codable {
    let data: [Data]?
    
    struct Data : Codable {
        let thumbnail: String
        let id: Int
        let fileName: String
        let ratingsInfo: RatingsInfo
        
        struct RatingsInfo : Codable {
            let average: Double
            let count: Int
        }
    }
}
