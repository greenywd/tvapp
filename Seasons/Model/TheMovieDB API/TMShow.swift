//
//  TMShow.swift
//  Seasons
//
//  Created by Thomas Greenwood on 15/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

struct TMShow : Decodable {
    let backdropPath: String?
    // let createdBy : [Created_by]?
    let episodeRunTime: [Int]? = nil
    let firstAirDate: String?
    // let genres : [Genres]?
    let homepage: String? = nil
    let id: Int?
    let inProduction: Bool? = nil
    let languages: [String]? = nil
    let lastAirDate: String? = nil
    let lastEpisodeToAir : TMShowLastNextEpisode? = nil
    let name: String?
    let nextEpisodeToAir : TMShowLastNextEpisode? = nil
    // let networks : [Networks]?
    let numberOfEpisodes: Int? = nil
    let numberofSeasons: Int? = nil
    let originCountry: [String]?
    let originalLanguage: String?
    let originalName: String?
    let overview: String?
    let popularity: Double?
    let posterPath: String?
    // let production_companies : [Production_companies]?
    // let seasons : [Seasons]?
    let status: String? = nil
    let type: String? = nil
    let voteAverage: Double?
    let voteCount: Int?

    var debugDescription: String {
        return self.name ?? "Unknown Name"
    }
    
    enum CodingKeys: String, CodingKey {

        case backdropPath = "backdrop_path"
        // case createdBy = "created_by"
        case episodeRunTime = "episode_run_time"
        case firstAirDate = "first_air_date"
        // case genres = "genres"
        case homepage, id
        case inProduction = "in_production"
        case languages
        case lastAirDate = "last_air_date"
        case lastEpisodeToAir = "last_episode_to_air"
        case name
        case nextEpisodeToAir = "next_episode_to_air"
        // case networks = "networks"
        case numberOfEpisodes = "number_of_episodes"
        case numberofSeasons = "number_of_seasons"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview, popularity
        case posterPath = "poster_path"
        // case production_companies = "production_companies"
        // case seasons = "seasons"
        case status, type
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    init(from searchResult: TMSearchResult) {
        self.backdropPath = searchResult.backdropPath
        self.originalName = searchResult.originalName
        // Genres?
        self.name = searchResult.name
        self.popularity = searchResult.popularity
        self.originCountry = searchResult.originCountry
        self.voteCount = searchResult.voteCount
        self.firstAirDate = searchResult.firstAirDate
        self.originalLanguage = searchResult.originalLanguage
        self.id = searchResult.id
        self.voteAverage = searchResult.voteAverage
        self.overview = searchResult.overview
        self.posterPath = searchResult.posterPath
    }
}
