//
//  UserDefaultsWrapper.swift
//  Seasons
//
//  Created by Thomas Greenwood on 21/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI
import Combine

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

final class UserSettings: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    @UserDefault("theme", defaultValue: 0)
    var theme: Int {
        didSet {
            didChange.send()
        }
    }
    @UserDefault("sendEpisodeNotifications", defaultValue: true)
    var sendEpisodeNotifications: Bool {
        didSet {
            didChange.send()
            if (!_sendEpisodeNotifications.defaultValue) {
                PersistenceService.removeScheduledNotifications()
            }
        }
    }
    @UserDefault("preferFullHD", defaultValue: true)
    var preferFullHD: Bool {
        didSet {
            didChange.send()
        }
    }
}
