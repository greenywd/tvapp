//
//  Network+CoreDataClass.swift
//  Seasons
//
//  Created by Thomas Greenwood on 25/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Network)
public class Network: NSManagedObject, Decodable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Network", in: context) else { fatalError() }
        
        self.init(entity: entity, insertInto: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            originCountry = try values.decode(String.self, forKey: .originCountry)
            name = try values.decode(String.self, forKey: .name)
            id = try values.decode(Int16.self, forKey: .id)
            logoPath = try values.decode(String.self, forKey: .logoPath)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, id
        case originCountry = "origin_country"
        case logoPath = "logo_path"
    }
}
