//
//  TMShowCreatedBy.swift
//  Seasons
//
//  Created by Thomas Greenwood on 18/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

// MARK: - CreatedBy
struct TMShowCreatedBy: Codable {
    let id: Int
    let creditID, name: String
    let gender: Int
    let profilePath: String

    enum CodingKeys: String, CodingKey {
        case id
        case creditID = "credit_id"
        case name, gender
        case profilePath = "profile_path"
    }
}
