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
            airDate = try values.decode(Date.self, forKey: .airDate)
            episodeCount = try values.decode(Int16.self, forKey: .episodeCount)
            
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeCount = "episode_count"
        case id, name, overview
        case posterPath = "poster_path"
        case seasonNumber = "season_number"
    }
}
