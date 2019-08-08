//
//  SettingsView.swift
//  Seasons
//
//  Created by Thomas Greenwood on 6/8/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State var testToggle = true
    var body: some View {
        NavigationView {
            List {
                Toggle (isOn: $testToggle){
                    Text("Toggle")
                }.padding()
                
                if testToggle {
                    Text("Hello!")
                }
            }
        .navigationBarTitle("Settings")
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
