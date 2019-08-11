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
    
    var selection: Int = (UIApplication.shared.windows.first?.traitCollection.userInterfaceStyle.rawValue)! {
        didSet {
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
                case .light:
                    return "Light"
                case .dark:
                    return "Dark"
                case .automatic:
                    return "Automatic"
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
                    NavigationLink(destination: SettingsDebugView()) {
                        VStack (alignment: .leading) {
                            Text("Debugging")
                                .font(.headline)
                            Text("If you're having issues, try some of the actions here.")
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

// MARK: Debug View
struct SettingsDebugView: View {
    var body: some View {
        List {
            Button(action: { PersistenceService.dropTable() }) {
                Text("Remove all Favourites")
                    .foregroundColor(Color.blue)
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
            Text("Version 1.0").foregroundColor(Color.secondary)
        }
        .navigationBarTitle("About")
    }
}

// MARK: Privacy Policy View
struct SettingsPrivacyPolicyView: View {
    var body: some View {
        VStack {
            Text("The privacy policy is simple: no personal data shared with us will be given to any third party, under any circumstances. Your data will also never be used by us for any purpose without specific permission.")
            Text("Seasons itself engages in no ad targeting, data mining, or other activities that may compromise your privacy, however ")
            Spacer()
        }
        .navigationBarTitle("Privacy Policy")
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
