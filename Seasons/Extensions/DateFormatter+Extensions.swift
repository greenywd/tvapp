//
//  DateFormatter+Extensions.swift
//  Seasons
//
//  Created by Thomas Greenwood on 9/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

private var cachedFormatters = [String : DateFormatter]()
enum DateFormatterType: String {
    case iso8601 = "yyyy-MM-dd", friendly = "EEE d MMM YYYY"
}
extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static func cached(type: DateFormatterType) -> DateFormatter {
        let formatter = DateFormatter()
        if (type == .iso8601) {
            if let cachedFormatter = cachedFormatters[type.rawValue] { return cachedFormatter }
            formatter.dateFormat = type.rawValue
            cachedFormatters[type.rawValue] = formatter
        } else {
            if let cachedFormatter = cachedFormatters[DateFormatterType.friendly.rawValue] { return cachedFormatter }
            formatter.dateFormat = DateFormatterType.friendly.rawValue
            cachedFormatters[DateFormatterType.friendly.rawValue] = formatter
        }
        return formatter
    }
}
