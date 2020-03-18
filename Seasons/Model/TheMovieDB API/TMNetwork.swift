//
//  TMNetwork.swift
//  Seasons
//
//  Created by Thomas Greenwood on 18/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

// MARK: - Network
struct TMNetwork: Codable {
    let name: String
    let id: Int
    let logoPath, originCountry: String

    enum CodingKeys: String, CodingKey {
        case name, id
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}
