//
//  Show+CoreDataClass.swift
//  Seasons
//
//  Created by Thomas Greenwood on 25/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Show)
public class Show: NSManagedObject, Decodable {
    public required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Show", in: PersistenceService.context) else { fatalError() }

        self.init(entity: entity, insertInto: nil)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            backdropPath = try values.decode(String.self, forKey: .backdropPath)
            // createdBy = NSSet(array: try values.decode([Creator].self, forKey: .createdBy))
            genres = NSSet(array: try values.decode([Genre].self, forKey: .genres))
            name = try values.decode(String.self, forKey: .name)
            firstAirDate = try values.decode(Date.self, forKey: .firstAirDate)
            homepage = try values.decode(String.self, forKey: .homepage)
            lastEpisodeToAir = try values.decode(Episode.self, forKey: .lastEpisodeToAir)
            name = try values.decode(String.self, forKey: .name)
            nextEpisodeToAir = try values.decode(Episode.self, forKey: .nextEpisodeToAir)
            networks = try NSSet(array: values.decode([Network].self, forKey: .networks))
            numberOfEpisodes = try values.decode(Int16.self, forKey: .numberOfEpisodes)
            numberOfSeasons = try values.decode(Int16.self, forKey: .numberOfSeasons)
            originCountry = try values.decode([String].self, forKey: .originCountry)
            originalLanguage = try values.decode(String.self, forKey: .originalLanguage)
            originalName = try values.decode(String.self, forKey: .originalName)
            overview = try values.decode(String.self, forKey: .overview)
            popularity = try values.decode(Double.self, forKey: .popularity)
            posterPath = try values.decode(String.self, forKey: .posterPath)
            seasons = NSSet(array: try values.decode([Season].self, forKey: .seasons))
            status = try values.decode(String.self, forKey: .status)
            type = try values.decode(String.self, forKey: .type)
            voteAverage = try values.decode(Double.self, forKey: .voteAverage)
            voteCount = try values.decode(Int16.self, forKey: .voteCount)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case createdBy = "created_by"
        case episodeRunTime = "episode_run_time"
        case firstAirDate = "first_air_date"
        case genres = "genres"
        case homepage, id
        case inProduction = "in_production"
        case languages
        case lastAirDate = "last_air_date"
        case lastEpisodeToAir = "last_episode_to_air"
        case name
        case nextEpisodeToAir = "next_episode_to_air"
        case networks = "networks"
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview, popularity
        case posterPath = "poster_path"
        case production_companies = "production_companies"
        case seasons = "seasons"
        case status, type
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

extension CodingUserInfoKey {
   static let context = CodingUserInfoKey(rawValue: "context")
}
