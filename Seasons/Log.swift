//
//  Log.swift
//  Seasons
//
//  Created by Thomas Greenwood on 6/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import os
import Foundation

extension OSLog {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let networking = OSLog(subsystem: subsystem, category: "Networking")
    static let coredata = OSLog(subsystem: subsystem, category: "Core Data")
    static let userdefaults = OSLog(subsystem: subsystem, category: "User Defaults")
    static let ui = OSLog(subsystem: subsystem, category: "User Interface")
    static let backgrounding = OSLog(subsystem: subsystem, category: "Background App Refresh")
    static let notifications = OSLog(subsystem: subsystem, category: "User Notifications")
    static let TMDBAPI = OSLog(subsystem: subsystem, category: "TheMovieDB API")
}
