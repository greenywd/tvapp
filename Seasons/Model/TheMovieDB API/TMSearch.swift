//
//  TMSearch.swift
//  Seasons
//
//  Created by Thomas Greenwood on 15/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation

struct TMSearch : Decodable {
    let page, totalResults, totalPages: Int
    let results: [TMSearchResult]?

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}
