//
//  Crew+CoreDataClass.swift
//  Seasons
//
//  Created by Thomas Greenwood on 25/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Crew)
public class Crew: NSManagedObject, Decodable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Crew", in: context) else { fatalError() }

        self.init(entity: entity, insertInto: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            creditID = try values.decode(String.self, forKey: .creditID)
            department = try values.decode(String.self, forKey: .department)
            gender = try values.decode(Int16.self, forKey: .gender)
            id = try values.decode(Int32.self, forKey: .id)
            job = try values.decode(String.self, forKey: .job)
            name = try values.decode(String.self, forKey: .name)
            profilePath = try values.decode(String.self, forKey: .profilePath)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case creditID = "credit_id"
        case department, gender, id, job, name
        case profilePath = "profile_path"
    }

}
