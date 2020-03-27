//
//  Genre+CoreDataClass.swift
//  Seasons
//
//  Created by Thomas Greenwood on 25/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Genre)
public class Genre: NSManagedObject, Decodable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Genre", in: context) else { fatalError() }

        self.init(entity: entity, insertInto: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try values.decode(Int16.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name
    }
}
