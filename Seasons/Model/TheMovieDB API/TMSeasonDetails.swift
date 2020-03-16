//
//  TMSeasonDetails.swift
//  Seasons
//
//  Created by Thomas Greenwood on 16/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

struct TMSeasonDetails: Decodable {
    let id, airDate: String
    let episodes: [TMEpisode]?
    let name, overview: String
    let seasonID: Int
    let posterPath: String
    let seasonNumber: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case airDate = "air_date"
        case episodes, name, overview
        case seasonID = "id"
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
    }
}
