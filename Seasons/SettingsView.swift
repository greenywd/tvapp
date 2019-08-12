//
//  SettingsView.swift
//  Seasons
//
//  Created by Thomas Greenwood on 6/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI
import Combine

final class ThemeChanger: Identifiable, ObservableObject {
    var didChange = PassthroughSubject<ThemeChanger, Never>()
    
    // FIXME: Save the theme preference, and load upon app startup. Currently this setting applies, but isn't remembered between app loads.
    var selection: Int = (UIApplication.shared.windows.first?.traitCollection.userInterfaceStyle.rawValue)! {
        didSet {
            print("Currently: \(selection)")
            if selection == 0 {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
            } else if selection == 1 {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            } else {
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var themeControl = ThemeChanger()
    
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
    @State var recieveUpdateNotification = true
    var body: some View {
        List {
            VStack (alignment: .leading) {
                Toggle(isOn: $recieveUpdateNotification) {
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

// MARK: Support View
struct SettingsSupportView: View {
    var body: some View {
        List {
            Text("Before doing anything, check to see whether your issue is known!")
                .font(.subheadline)
            
            Button(action: { PersistenceService.dropTable() }) {
                Text("Known Issues")
                    .foregroundColor(Color.accentColor)
            }
            
            VStack (alignment: .leading) {
                NavigationLink(destination: SettingsDebugView()) {
                    VStack (alignment: .leading) {
                        Text("Debugging")
                            .font(.headline)
                        Text("If you're having issues, try some of the actions here.")
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationBarTitle("Support")
    }
}

// MARK: Debug View
struct SettingsDebugView: View {
    var body: some View {
        List {
            VStack (alignment: .leading) {
                Button(action: { PersistenceService.dropTable() }) {
                    Text("Remove all Favourites")
                        .foregroundColor(Color.orange)
                }
                Text("This does exactly what it sounds like. Proceed with caution")
                    .font(.footnote)
            }
        }
        .navigationBarTitle("Debugging")
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
