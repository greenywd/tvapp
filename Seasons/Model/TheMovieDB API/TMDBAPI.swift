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
    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
    }
    
    private static func createRequest(with url: URL, method: HTTPMethod/*, needsToken: Bool*/) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        // TODO: Implement later
        //        if needsToken {
        //            request.setValue("Bearer \(TVDBAPI.currentToken)", forHTTPHeaderField: "Authorization")
        //        }
        
        return request
    }
    
    static func getShow(id: Int32, completion: @escaping (Show?) -> Void) {
        let showEndpoint = "https://api.themoviedb.org/3/tv/\(id)?api_key=\(TMDBAPIKey)&language=en-US"
        
        guard let seriesURL = URL(string: showEndpoint) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: seriesURL, method: .get)
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            os_log("Getting show with ID: %d", log: .networking, type: .info, id)
            
            // make sure we got data
            guard let responseData = data else {
                os_log("Did not receive any data for %@", log: .networking, type: .error, #function)
                return
            }
            
            do {
                let showInfo = try JSONDecoder().decode(Show.self, from: responseData)
                os_log("Retrieved data for %@", log: .networking, type: .info, showInfo.debugDescription)
                completion(showInfo)
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        showTask.countOfBytesClientExpectsToReceive = 3500 // round up from ~3447
        showTask.resume()
    }
    
    static func searchShows(query: String, page: Int = 1, completion: @escaping ([TMSearchResult]?) -> Void) {
        var searchURLString = "https://api.themoviedb.org/3/search/tv?api_key=\(TMDBAPIKey)&language=en-US&query=\(query)&page=\(page)"
        
        if let encoded = searchURLString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let encodedURL = URL(string: encoded) {
            searchURLString = encodedURL.absoluteString
        }
        
        guard let searchURL = URL(string: searchURLString) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: searchURL, method: .get)
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                os_log("Request failed for %@ with %@", log: .networking, type: .error, #function, error.debugDescription)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                os_log("Did not receive any data for %@", log: .networking, type: .error, #function)
                return
            }
            
            do {
                let search = try JSONDecoder().decode(TMSearch.self, from: responseData)
                
                guard let searchResults = search.results else {
                    os_log("No shows returned from search.", log: .networking, type: .info)
                    completion(nil)
                    return
                }
                
                completion(searchResults)
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        
        showTask.resume()
    }
    
    static func getEpisodes(show: Int32, season: Int16, completion: @escaping ([Episode]?) -> Void) {
        let episodeURLString = "https://api.themoviedb.org/3/tv/\(show)/season/\(season)?api_key=\(TMDBAPIKey)&language=en-US"
        
        guard let episodesURL = URL(string: episodeURLString) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: episodesURL, method: .get)
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                os_log("Request failed for %@ with %@", log: .networking, type: .error, #function, error.debugDescription)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                os_log("Did not receive any data for %@", log: .networking, type: .error, #function)
                return
            }
            
            do {
                let seasonDetails = try JSONDecoder().decode(Season.self, from: responseData)
                
                guard let episodes = seasonDetails.episodes else {
                    os_log("No shows returned from search.", log: .networking, type: .info)
                    completion(nil)
                    return
                }
                
                completion(episodes.allObjects as? [Episode])
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        
        showTask.resume()
    }
    
    // MARK: - Helper Functions
    enum ImageType {
        case backdrop, logo, poster, profile
    }
    
    static func createImageURL(path: String, imageType: ImageType) -> URL? {
        if let fullURL = URL(string: "https://image.tmdb.org/t/p/original\(path)") {
            return fullURL
        }
        
        return nil
    }
}
