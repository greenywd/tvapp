//
//  TabView.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 14/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

struct TabView : View {
    var body: some View {
        TabbedView {
            HomeView()
                .tabItemLabel (
                    Text("Home")
            ).tag(0)
            
            SearchView()
                .tabItemLabel(
                    Text("Search")
            ).tag(1)
        }
    }
}

#if DEBUG
struct TabView_Previews : PreviewProvider {
    static var previews: some View {
        TabView()
            .previewDevice("iPhone XS Max")
    }
}
#endif
