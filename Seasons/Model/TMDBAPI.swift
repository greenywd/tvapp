//
//  TMDBAPI.swift
//  Seasons
//
//  Created by Thomas Greenwood on 13/3/20.
//  Copyright © 2020 Thomas Greenwood. All rights reserved.
//

import Foundation
import os

class TMDBAPI {
    func getShow(id: Int32, completion: @escaping (Show?) -> Void) {
        
    }
    
    func searchShows(query: String, completion: @escaping (ShowSearchResults?) -> Void) {
        
    }
    
    func getEpisodes(for show: Int32, completion: @escaping ([Episode]?) -> Void) {
        
    }
    
    func getLatestEpisode(for show: Int32, completion: @escaping (Episode?) -> Void) {
        
    }
    
    func getImageURLs(for show: Int32, completion: @escaping ([Images]?) -> Void) {
        
    }
}
