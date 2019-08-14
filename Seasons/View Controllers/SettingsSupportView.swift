//
//  SettingsSupportView.swift
//  Seasons
//
//  Created by Thomas Greenwood on 14/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

// MARK: Support View
struct SettingsSupportView: View {
    var body: some View {
        List {
            Section(header: Text("Start here!")) {
                Button(action: {
                    if let url = URL(string: "https://www.github.com/greenywd/tvapp/issues") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    VStack (alignment: .leading) {
                        Text("Known Issues")
                            .font(.headline)
                        Text("Before doing anything, check to see whether your issue is known!")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                }
            }
            Section(header: Text("Not known?")) {
                VStack (alignment: .leading) {
                    NavigationLink(destination: SettingsDebugView()) {
                        VStack (alignment: .leading) {
                            Text("Debugging")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("If you're having issues, try some of the actions here.")
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            Section(header: Text("Still having issues?")) {
                Button(action: {
                    if let url = URL(string: "https://www.github.com/greenywd/tvapp/issues/new") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    VStack (alignment: .leading) {
                        Text("Report a bug (GitHub)")
                            .font(.headline)
                        Text("Report a bug on Github. Requires a GitHub account.")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                }
                
                Button(action: {
                    if let url = URL(string: "") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    VStack (alignment: .leading) {
                        Text("Report a bug (Email)")
                            .font(.headline)
                        Text("Report a bug via email.")
                            .font(.footnote)
                            .foregroundColor(.primary)
                    }
                }
            }
        }.listStyle(GroupedListStyle())
            .navigationBarTitle("Support")
    }
}

// MARK: Debug View
struct SettingsDebugView: View {
    var body: some View {
        List {
            VStack (alignment: .leading) {
                Button(action: { /*TODO: Implement action */ }) {
                    Text("Force update Shows")
                        .foregroundColor(Color.orange)
                }
                Text("Updates all information for all shows. This may take some time and use some data.")
                    .font(.footnote)
            }
            
            VStack (alignment: .leading) {
                Button(action: { PersistenceService.dropTable() }) {
                    Text("Remove all Favourites")
                        .foregroundColor(Color.orange)
                }
                Text("This does exactly what it sounds like. Proceed with caution.")
                    .font(.footnote)
            }
        }
        .navigationBarTitle("Debugging")
    }
}

#if DEBUG
struct SettingsSupportView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSupportView()
    }
}
#endif
