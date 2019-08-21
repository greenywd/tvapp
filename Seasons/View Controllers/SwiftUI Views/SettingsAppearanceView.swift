//
//  SettingsAppearanceView.swift
//  Seasons
//
//  Created by Thomas Greenwood on 21/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

// MARK: Appearance View
struct SettingsAppearanceView: View {
    @ObservedObject var settings = UserSettings()
    @ObservedObject var themeControl = ThemeChanger()
    
    var body: some View {
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
                Text("Image Resolution")
                    .font(.headline)
                Text("Select which image resolution is preferred. If no images of the preference are available, the other will be used. Full HD will use more data than HD.")
                    .font(.subheadline)
                Picker(selection: $settings.preferFullHD, label: Text("Image Resolution")) {
                    Text("HD (1280x720)").tag(false)
                    Text("Full HD (1920x1080)").tag(true)
                }.pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationBarTitle("Appearance")
    }
}

struct SettingsAppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAppearanceView()
    }
}
