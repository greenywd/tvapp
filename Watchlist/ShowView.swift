//
//  ShowView.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 13/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

struct ShowView : View {
    var body: some View {
        VStack {
            Image("blackmirror")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .padding(-20)
        }
    }
}

#if DEBUG
struct ShowView_Previews : PreviewProvider {
    static var previews: some View {
        ShowView()
    }
}
#endif
