//
//  Season+CoreDataClass.swift
//  Seasons
//
//  Created by Thomas Greenwood on 25/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Season)
public class Season: NSManagedObject, Decodable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Season", in: context) else { fatalError() }
        
        self.init(entity: entity, insertInto: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            airDate = try values.decodeIfPresent(Date.self, forKey: .airDate)
            episodeCount = try values.decodeIfPresent(Int16.self, forKey: .episodeCount) ?? 0
            id = try values.decode(Int32.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            episodes = NSSet(array: try values.decodeIfPresent([Episode].self, forKey: .episodes) ?? [])
            overview = try values.decode(String.self, forKey: .overview)
            posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
            seasonNumber = try values.decode(Int16.self, forKey: .seasonNumber)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeCount = "episode_count"
        case id, name, overview, episodes
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
    }
}
