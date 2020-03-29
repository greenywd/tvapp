//
//  TMSearchResult.swift
//  Seasons
//
//  Created by Thomas Greenwood on 15/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation
import CoreData

struct TMSearchResult: Decodable {
    let originalName: String
    let genreIDS: [Int]
    let name: String
    let popularity: Double
    let originCountry: [String]
    let voteCount: Int
    let firstAirDate: String?
    let backdropPath: String?
    let originalLanguage: String
    let id: Int
    let voteAverage: Double
    let overview: String
    let posterPath: String?

    enum CodingKeys: String, CodingKey {
        case originalName = "original_name"
        case genreIDS = "genre_ids"
        case name, popularity
        case originCountry = "origin_country"
        case voteCount = "vote_count"
        case firstAirDate = "first_air_date"
        case backdropPath = "backdrop_path"
        case originalLanguage = "original_language"
        case id
        case voteAverage = "vote_average"
        case overview
        case posterPath = "poster_path"
    }
    
    func convertToShow() -> Show {
        let show = Show(context: PersistenceService.temporaryContext)
        show.name = self.name
        show.overview = self.overview
        show.id = Int32(self.id)
        return show
    }
}
