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
    let links: Links?
    
    struct Data : Codable {
        let airedEpisodeNumber: Int32
        let overview: String?
        let guestStars: [String]
        let id: Int32
        let imdbId: String
        let filename: String
        let director: String
        let airedSeason: Int32
        // let siteRating: Double
        let episodeName: String?
        // let writers: [String]
        // let directors: [String]
        let seriesId: Int32
        let firstAired: String
    }
    
    struct Links : Codable {
        let first: Int32?
        let last: Int32?
        let next: Int32?
        let prev: Int32?
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

struct API_EpisodeSummary : Codable {
    let data: Data?
    
    struct Data : Codable {
        let airedEpisodes: String?
        let airedSeasons: [String]?
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

/*
 └ curl -X GET --header 'Content-Type: application/json' --header 'Accept: application/json' --header 'Authorization: Bearer <token>' 'https://api.thetvdb.com/series/257655/episodes'
 {
 "links": {
 "first": 1,
 "last": 2,
 "next": 2,
 "prev": null
 },
 "data": [
 {
 "id": 4325893,
 "airedSeason": 1,
 "airedSeasonID": 492243,
 "airedEpisodeNumber": 1,
 "episodeName": "Pilot",
 "firstAired": "2012-10-10",
 "guestStars": [
 "Colin Salmon",
 "Jamey Sheridan",
 "Jacqueline MacInnes Wood",
 "Annie Ilonzeh",
 "Kathleen Gati",
 "Roger Cross",
 "Brian Markinson",
 "Ben Cotton"
 ],
 "director": "|David Nutter|",
 "directors": [
 "David Nutter"
 ],
 "writers": [
 "Greg Berlanti",
 "Marc Guggenheim",
 "Andrew Kreisberg"
 ],
 "overview": "After a violent shipwreck, billionaire playboy Oliver Queen was missing and presumed dead for five years before being discovered alive on a remote island in the Pacific. Back in Starling City, Oliver slowly reconnects with those closest to him. Oliver has brought back many new skills from his time on the island and despite the watchful eye of his new bodyguard John Diggle, Oliver manages to secretly create the persona of Arrow – a vigilante – to right the wrongs of his family and fight the ills of society. As Arrow, Oliver will atone for the past sins of his family while he searches for the personal redemption he needs.",
 "language": {
 "episodeName": "en",
 "overview": "en"
 },
 "productionCode": "2J7347",
 "showUrl": "",
 "lastUpdated": 1535867618,
 "dvdDiscid": "",
 "dvdSeason": 1,
 "dvdEpisodeNumber": 1,
 "dvdChapter": null,
 "absoluteNumber": 1,
 "filename": "episodes/257655/4325893.jpg",
 "seriesId": 257655,
 "lastUpdatedBy": 384674,
 "airsAfterSeason": null,
 "airsBeforeSeason": null,
 "airsBeforeEpisode": null,
 "thumbAuthor": 268831,
 "thumbAdded": "",
 "thumbWidth": "400",
 "thumbHeight": "225",
 "imdbId": "tt2340185",
 "siteRating": 7.7,
 "siteRatingCount": 242
 }
 ]
 }
 */
struct Episode : Equatable {
    let id: Int32?
    let overview: String?
    let airedEpisodeNumber: Int32?
    let airedSeason: Int32?
    let episodeName: String?
    let firstAired: String?
    let filename: String?
    let seriesId: Int32?
    
    static func ==(lhs: Episode, rhs: Episode) -> Bool {
        return lhs.id == rhs.id
    }
}

struct EpisodeSummary {
    let airedEpisodes: String?
    let airedSeasons: [String]?
}
