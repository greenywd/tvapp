//
//  SettingsAboutView.swift
//  Seasons
//
//  Created by Thomas Greenwood on 15/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import SwiftUI

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
            Text("TV information and images are provided by TheTVDB.com, but we are not endorsed or certified by TheTVDB.com or its affiliates.")
        }
        .navigationBarTitle("Credits")
    }
}

#if DEBUG
struct SettingsAboutView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAboutView()
    }
}
#endif
