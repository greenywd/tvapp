//
//  TMSeason.swift
//  Seasons
//
//  Created by Thomas Greenwood on 30/5/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

struct TMSeason : Decodable {
    let airDate: String
    let episodeCount: Int?
    let episodes: [Episode]?
    let id: Int
    let name: String
    let overview: String
    let posterPath: String
    let seasonNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeCount = "episode_count"
        case id, name, overview, episodes
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
    }
}
