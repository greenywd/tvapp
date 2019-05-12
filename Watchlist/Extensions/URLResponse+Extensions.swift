//
//  URLResponse+Extensions.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 20/4/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

extension URLResponse {
    var StatusCode: Int {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return -1
    }
}
