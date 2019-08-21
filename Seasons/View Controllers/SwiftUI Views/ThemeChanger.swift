//
//  ThemeChanger.swift
//  Seasons
//
//  Created by Thomas Greenwood on 21/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Combine
import SwiftUI

final class ThemeChanger: ObservableObject {
    @ObservedObject var settings = UserSettings()
    
    var didChange = PassthroughSubject<ThemeChanger, Never>()
    
    var selection: Int = UserDefaults.standard.integer(forKey: "theme") {
        didSet {
            print("Currently: \(selection)")
            if selection == 0 {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
                settings.theme = 0
            } else if selection == 1 {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
                settings.theme = 1
            } else {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
                settings.theme = 2
            }
            print(settings.theme)
        }
    }
}
