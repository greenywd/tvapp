//
//  HomeView.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 11/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

struct HomeView : View {
    var body: some View {
        NavigationView {
            List(testShows) { show in
                ShowRow(show: show)
                }
                .navigationBarTitle(Text("Shows"))
        }
    }
}

#if DEBUG
struct HomeView_Previews : PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
