//
//  ShowRow.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 11/6/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI

struct ShowRow : View {
    var show: Show
    
    var body: some View {
        ZStack {
            if (self.) {
                Image(show.banner)
                    .resizable()
                    .overlay(
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.clear, .white]), startPoint: .center, endPoint: .bottom))
                            .clipped()
                    )
                    .cornerRadius(10, antialiased: true)
            }
            
            HStack {
                Text(show.seriesName)
                    .fontWeight(.heavy)
                Text(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/)
                
                Spacer()
                Text("12th June")
                }
                .padding()
                .offset(y: 50)
            }
            .frame(height: 150)
    }
}

#if DEBUG
struct ShowRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            ShowRow(show: testShows[0]).environment(\.colorScheme, .dark)
            ShowRow(show: testShows[1]).environment(\.colorScheme, .light)
            }.previewLayout(.sizeThatFits)
    }
}
#endif
