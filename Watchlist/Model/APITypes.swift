//
//  APITypes.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 12/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
// MARK: Types returned from the TVDBAPI
// TODO: Update all types to match API. Documentation says most of these are optional.


/// Type used with JSON Decoding of authenticating with the TVDBAPI.
struct API_Authentication : Codable {
    
    /// Current token retrieved from the API.
    let token: String?
    fileprivate let Error: String?
}

struct API_Show : Codable {
    var Error: String?
    let data: Data?
    
    struct Data : Codable {
        var id: Int32
        var overview: String?
        var seriesName: String?
        let banner: String?
        let status: String?
        let runtime: String?
        let network: String?
    }
}

struct API_Episodes : Codable {
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
        let episodeName: String?
        // let writers: [String]
        // let directors: [String]
        let seriesId: Int
        let firstAired: String
    }
}

struct API_SearchResults : Codable {
    let data: [Data]?
    
    struct Data : Codable {
        let aliases: [String]?
        let banner: String?
        let firstAired: String?
        let id: Int32
        let network: String?
        let overview: String?
        let seriesName: String?
        let status: String?
    }
}

struct API_Images : Codable {
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

// MARK: Custom types to aid the API_Types

/// Type used with 'Search' and 'Show' View Controllers. Contains relevant information from the `API_SearchResults` and `API_Show` types.
struct Show {
    var id: Int32
    var overview: String? = "No Overview Available"
    var seriesName: String? = "Unknown Series Title"
    let banner: String?
    let status: String?
    let runtime: String?
    let network: String?
}
