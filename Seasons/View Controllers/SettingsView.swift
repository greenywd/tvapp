//
//  SettingsView.swift
//  Seasons
//
//  Created by Thomas Greenwood on 6/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI
import Combine

final class ThemeChanger: ObservableObject {
    @ObservedObject var settings = UserSettings()
    
    var didChange = PassthroughSubject<ThemeChanger, Never>()
    
    // FIXME: Save the theme preference, and load upon app startup. Currently this setting applies, but isn't remembered between app loads.
    var selection: Int = UserDefaults.standard.object(forKey: "theme") as! Int {
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

enum Theme: Int {
    case automatic, light, dark
    
    var description: String {
        get {
            switch self {
            case .automatic:
                return "Automatic"
            case .light:
                return "Light"
            case .dark:
                return "Dark"
                
            }
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
    @UserDefault("showUpdateNotification", defaultValue: true)
    var showUpdateNotification: Bool {
        didSet {
            didChange.send()
        }
    }
}

struct SettingsView: View {
    @ObservedObject var themeControl = ThemeChanger()
    @ObservedObject var settings = UserSettings()
    
    var body: some View {
        NavigationView {
            List {
                VStack (alignment: .leading) {
                    Text("Theme")
                        .font(.headline)
                    Text("Automatic will follow the system setting.")
                        .font(.subheadline)
                    Picker(selection: $themeControl.selection, label: Text("Theme")) {
                        ForEach(0..<3) {
                            Text(Theme(rawValue: $0)!.description)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                
                VStack (alignment: .leading) {
                    NavigationLink(destination: SettingsNotificationsView()) {
                        VStack (alignment: .leading) {
                            Text("Notifications")
                                .font(.headline)
                            Text("Customise how you recieve notifications.")
                                .font(.subheadline)
                        }
                    }
                }
                
                VStack (alignment: .leading) {
                    NavigationLink(destination: SettingsSupportView()) {
                        VStack (alignment: .leading) {
                            Text("Support")
                                .font(.headline)
                            Text("Get some help here!")
                                .font(.subheadline)
                        }
                    }
                }
                
                VStack (alignment: .leading) {
                    NavigationLink(destination: SettingsAboutView()) {
                        VStack (alignment: .leading) {
                            Text("About")
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationBarTitle("Settings")
            
        }
    }
}

// MARK: Notifications View
struct SettingsNotificationsView: View {
    @ObservedObject var settings = UserSettings()
    var body: some View {
        List {
            VStack (alignment: .leading) {
                Toggle(isOn: $settings.showUpdateNotification) {
                    Text("Show Updates")
                        .font(.headline)
                }
                Text("Receive a notification when a favourite show is updated with new information, i.e. new episodes.")
                    .font(.subheadline)
            }
            .navigationBarTitle("Notifications")
        }
    }
}

// MARK: About View
struct SettingsAboutView: View {
    var body: some View {
        List {
            NavigationLink(destination: SettingsPrivacyPolicyView()) {
                Text("Privacy Policy")
                    .font(.headline)
            }
            NavigationLink(destination: SettingsCreditsView()) {
                Text("Credits")
                    .font(.headline)
            }
            Text("Version 1.0")
                .foregroundColor(Color.secondary)
        }
        .navigationBarTitle("About")
    }
}

// MARK: Privacy Policy View
struct SettingsPrivacyPolicyView: View {
    var body: some View {
        VStack {
            Text("The privacy policy is simple: no personal data shared with myself will be given to any third party, under any circumstances. By default, no data is collected by Seasons. However, information (such as crash reports) may be collected to improve Seasons based on your device settings. Seasons retrieves data from thetvdb.com, who may collect and use your data in accordance with their privacy policy. Seasons itself engages in no ad targeting, data mining, or other activities that may compromise your privacy.")
                .padding()
            Spacer()
        }
        .navigationBarTitle("Privacy Policy")
    }
}

// MARK: Credits View
struct SettingsCreditsView: View {
    var body: some View {
        VStack {
            Text("Thanks to:")
                .font(.headline)
            Text("Wilson for the name")
            Spacer()
        }
        .navigationBarTitle("Credits")
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
