//
//  SearchView.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 14/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

struct SearchView : View {
    @State private var searchShow = ""
    @State private var searchResults = testShows
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                TextField($searchShow, placeholder: Text("Text"))
                    .border(Color.gray, cornerRadius: 7.5)
                .padding()
                }
                List (searchResults) { show in
                    ShowRow(show: show, type: .descriptive)
                }
            }
            .navigationBarTitle(Text("Search"))
        }

    }
}

#if DEBUG
struct SearchView_Previews : PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
#endif
