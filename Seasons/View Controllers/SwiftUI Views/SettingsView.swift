//
//  SettingsView.swift
//  Seasons
//
//  Created by Thomas Greenwood on 6/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var settings = UserSettings()
    
    var body: some View {
        NavigationView {
            List {
                VStack (alignment: .leading) {
                    NavigationLink(destination: SettingsAppearanceView()) {
                        VStack (alignment: .leading) {
                            Text("Appearance")
                                .font(.headline)
                            Text("Chance the appearance of Seasons.")
                                .font(.subheadline)
                        }
                    }
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
        }
        .navigationBarTitle("Notifications")
    }
}


#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
