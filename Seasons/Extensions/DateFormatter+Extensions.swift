//
//  DateFormatter+Extensions.swift
//  Seasons
//
//  Created by Thomas Greenwood on 9/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

extension DateFormatter {
  static let yyyyMMdd: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
