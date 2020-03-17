//
//  TMFind.swift
//  Seasons
//
//  Created by Thomas Greenwood on 17/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

struct TMFind: Codable {
    let tvResults: [TMFindResult]

    enum CodingKeys: String, CodingKey {
        case tvResults = "tv_results"
    }
}
