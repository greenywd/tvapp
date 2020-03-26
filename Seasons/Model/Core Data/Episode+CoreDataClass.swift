//
//  Episode+CoreDataClass.swift
//  Seasons
//
//  Created by Thomas Greenwood on 25/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Episode)
public class Episode: NSManagedObject, Decodable {

    public required convenience init(from decoder: Decoder) throws {
        // guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Episode", in: PersistenceService.context) else { fatalError() }

        self.init(entity: entity, insertInto: nil)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            airDate = try values.decode(Date.self, forKey: .airDate)
            crew = NSSet(array: try values.decode([Crew].self, forKey: .crew))
            episodeNumber = try values.decode(Int32.self, forKey: .episodeNumber)
            guestStars = NSSet(array: try values.decode([Guest].self, forKey: .guestStars))
            id = try values.decode(Int32.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            overview = try values.decode(String.self, forKey: .overview)
            productionCode = try values.decode(String.self, forKey: .productionCode)
            seasonNumber = try values.decode(Int16.self, forKey: .seasonNumber)
            showID = try values.decode(Int32.self, forKey: .showID)
            stillPath = try values.decode(String.self, forKey: .stillPath)
            voteAverage = try values.decode(Double.self, forKey: .voteAverage)
            voteCount = try values.decode(Int16.self, forKey: .voteCount)
        }
    }
    
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
        case crew
        case guestStars = "guest_stars"
    }
}
