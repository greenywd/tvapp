//
//  TMFindResult.swift
//  Seasons
//
//  Created by Thomas Greenwood on 17/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

// MARK: - TvResult
struct TMFindResult: Codable {
    let originalName: String
    let id: Int
    let name: String
    let voteCount: Int
    let voteAverage: Double
    let firstAirDate, posterPath: String
    let genreIDS: [Int]
    let originalLanguage, backdropPath, overview: String
    let originCountry: [String]
    let popularity: Double

    enum CodingKeys: String, CodingKey {
        case originalName = "original_name"
        case id, name
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case firstAirDate = "first_air_date"
        case posterPath = "poster_path"
        case genreIDS = "genre_ids"
        case originalLanguage = "original_language"
        case backdropPath = "backdrop_path"
        case overview
        case originCountry = "origin_country"
        case popularity
    }
}
