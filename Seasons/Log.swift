//
//  Log.swift
//  Seasons
//
//  Created by Thomas Greenwood on 6/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import os
import Foundation

private let subsystem = Bundle.main.bundleIdentifier!

struct Log {
    static let networking = OSLog(subsystem: subsystem, category: "Networking")
    static let coredata = OSLog(subsystem: subsystem, category: "Core Data")
    static let userdefaults = OSLog(subsystem: subsystem, category: "User Defaults")
}
