//
//  TMShowNextEpisode.swift
//  Seasons
//
//  Created by Thomas Greenwood on 16/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

struct TMShowLastNextEpisode: Codable {
    let airDate: String
    let episodeNumber, id: Int
    let name, overview, productionCode: String
    let seasonNumber, showID: Int
    let stillPath: String?
    let voteAverage, voteCount: Int

    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case id, name, overview
        case productionCode = "production_code"
        case seasonNumber = "season_number"
        case showID = "show_id"
        case stillPath = "still_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
