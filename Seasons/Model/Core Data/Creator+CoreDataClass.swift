//
//  Creator+CoreDataClass.swift
//  Seasons
//
//  Created by Thomas Greenwood on 25/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Creator)
public class Creator: NSManagedObject, Decodable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Creator", in: context) else { fatalError() }

        self.init(entity: entity, insertInto: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            creditID = try values.decode(String.self, forKey: .creditID)
            gender = try values.decode(Int16.self, forKey: .gender)
            id = try values.decode(Int32.self, forKey: .id)
            name = try values.decode(String.self, forKey: .name)
            profilePath = try values.decode(String.self, forKey: .profilePath)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case creditID = "credit_id"
        case name, gender
        case profilePath = "profile_path"
    }
}
