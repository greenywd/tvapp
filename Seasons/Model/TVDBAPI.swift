//
//  TVDBAPI.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 28/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import os

class TVDBAPI {
    
    /// An Enumerated type for declaring a resolution in the 16:9 aspect ratio.
    ///
    /// - HD: Returns "1280x720"
    /// - FHD: Returns "1920x1080"
    enum Resolution: String {
        case HD = "1280x720"
        case FHD = "1920x1080"
        
        func reversed() -> Resolution {
            if (self == .FHD) {
                return .HD
            }
            return .FHD
        }
    }
    
    private static var currentToken: String = ""
    
    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
    }
    
    private static func createRequest(with url: URL, method: HTTPMethod, needsToken: Bool) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if needsToken {
            request.setValue("Bearer \(TVDBAPI.currentToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    /// Retrieves a token from thetvdb.com
    ///
    /// - Parameters:
    ///   - key: API Key given by your account on thetvdb.com
    ///   - success: Callback after retrieval.
    ///   - error: A (hopefully) descriptive error if no data is retrieved, if JSON decoding goes wrong or an API error from thetvdb.com.
    
    static func retrieveToken(completion: @escaping () -> Void = {}) {
        // TODO: If token is expired (check status code/error) renew it
        let params = ["apikey" : APIKey]
        // FIXME: Proper error handling?
        let json = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let endpoint = URL(string: "https://api.thetvdb.com/login")!
        
        var request = createRequest(with: endpoint, method: .post, needsToken: false)
        request.httpBody = json
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                os_log("Did not receive any data for %@", log: .networking, type: .error, #function)
                return
            }
            
            os_log("Status Code: %@", log: .networking, type: .info, response!.StatusCode)
            
            do {
                let auth = try JSONDecoder().decode(API_Authentication.self, from: data)
                
                if let token = auth.token {
                    currentToken = token
                    os_log("Token set to: %@", log: .networking, token)
                    completion()
                }
                
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    static func getShow(id: Int32, completion: @escaping (Show?) -> Void = { _ in }) {
        let seriesEndpoint = "https://api.thetvdb.com/series/\(String(id))"
        
        guard let seriesURL = URL(string: seriesEndpoint) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: seriesURL, method: .get, needsToken: true)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            os_log("Getting show with ID: %d", log: .networking, type: .info, id)
            
            // make sure we got data
            guard let responseData = data else {
                os_log("Did not receive any data for %@", log: .networking, type: .error, #function)
                return
            }
            
            do {
                let showInfo = try JSONDecoder().decode(API_Show.self, from: responseData).data!
                os_log("Retrieved data for %@", log: .networking, type: .info, showInfo.debugDescription)
                completion(Show(from: showInfo))
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }.resume()
    }
    
    static func searchShows(show: String, completion: @escaping ([Show]?, String?) -> Void) {
        var searchURL = "https://api.thetvdb.com/search/series?name=\(show)"
        
        if let encoded = searchURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let encodedURL = URL(string: encoded) {
            searchURL = encodedURL.absoluteString
        }
        
        guard let seriesURL = URL(string: searchURL) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: seriesURL, method: .get, needsToken: true)
        
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
                let results = try JSONDecoder().decode(API_SearchResults.self, from: responseData)
                var shows = [Show]()
                
                guard let showsSearched = results.data else {
                    os_log("No shows returned from search.", log: .networking, type: .info)
                    completion(nil, results.Error)
                    return
                }
                
                for show in showsSearched {
                    shows.append(Show(from: show))
                }
                completion(shows, nil)
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    static func getEpisodes(show id: Int32, parameters: String? = nil, completion: @escaping ([Episode]?) -> Void) {
        var episodesURLEndpoint = "https://api.thetvdb.com/series/\(id)/episodes"
        let episodeGroup = DispatchGroup()
        
        if let param = parameters {
            episodesURLEndpoint += "/query?\(param)"
        }
        
        guard let episodesURL = URL(string: episodesURLEndpoint) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: episodesURL, method: .get, needsToken: true)
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // make sure we got data
            guard let responseData = data else {
                os_log("Did not receive any data for %@", log: .networking, type: .error, #function)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
                
                let results = try JSONDecoder().decode(API_Episodes.self, from: responseData)
                
                var episodes = [Episode]()
                if let data = results.data {
                    for episode in data {
                        episodes.append(Episode(id: episode.id, overview: episode.overview, airedEpisodeNumber: episode.airedEpisodeNumber, airedSeason: episode.airedSeason, episodeName: episode.episodeName, firstAired: DateFormatter.yyyyMMdd.date(from: episode.firstAired), filename: episode.filename, seriesId: episode.seriesId, hasWatched: false))
                    }
                    if let next = results.links?.next {
                        episodeGroup.enter()
                        getEpisodes(show: id, parameters: "page=\(next)", completion: { (episodes2) in
                            episodes.append(contentsOf: episodes2!)
                            episodeGroup.leave()
                        })
                    }
                }
                
                episodeGroup.notify(queue: .main ) {
                    completion(episodes)
                }
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        showTask.resume()
        
    }
    
    static func getImageURLs(show id: Int32, resolution: Resolution, completion: @escaping (API_Images?) -> Void = { _ in }) {
        let imagesURLEndpoint = "https://api.thetvdb.com/series/\(id)/images/query?keyType=fanart&resolution=\(resolution.rawValue)"
        
        guard let episodesURL = URL(string: imagesURLEndpoint) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: episodesURL, method: .get, needsToken: true)
        
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
                let images = try JSONDecoder().decode(API_Images.self, from: responseData)
                completion(images)
                
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    static func getEpisodeSummary(show id: Int32, completion: @escaping (EpisodeSummary?) -> Void) {
        let imagesURLEndpoint = "https://api.thetvdb.com/series/\(id)/episodes/summary"
        
        guard let episodesURL = URL(string: imagesURLEndpoint) else {
            os_log("Failed to create URL for %@", log: .networking, type: .error, #function)
            return
        }
        
        let request = createRequest(with: episodesURL, method: .get, needsToken: true)
        
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
            
            // dump(String(data: responseData, encoding: .utf8))
            
            do {
                let summary = try JSONDecoder().decode(API_EpisodeSummary.self, from: responseData)
                completion(EpisodeSummary(airedEpisodes: summary.data?.airedEpisodes, airedSeasons: summary.data?.airedSeasons?.sorted()))
                
            } catch {
                os_log("Failed to decode response with: %@", log: .networking, type: .error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
}
