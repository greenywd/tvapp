//
//  TVDBAPI.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 28/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

private protocol TVDBError : Error {
    var title: String { get }
}

class TVDBAPI {
    
    private struct TVError : TVDBError {
        var title: String
        
        init(title: String) {
            self.title = title
        }
    }
    
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
    
    /// Retrieves a token from thetvdb.com
    ///
    /// - Parameters:
    ///   - key: API Key given by your account on thetvdb.com
    ///   - success: Callback after retrieval.
    ///   - error: A (hopefully) descriptive error if no data is retrieved, if JSON decoding goes wrong or an API error from thetvdb.com.
    
    static func retrieveToken(completion: @escaping () -> () = {}) {
        // TODO: If token is expired (check status code/error) renew it
        let params = ["apikey" : APIKey]
        // FIXME: Proper error handling?
        let json = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let endpoint = URL(string: "https://api.thetvdb.com/login")
        
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.httpBody = json
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            print("Status Code: \(response!.StatusCode)")
            
            do {
                let auth = try JSONDecoder().decode(API_Authentication.self, from: data)
                
                if let token = auth.token {
                    currentToken = token
                    print("Token set to:", token)
                    completion()
                }
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    static func getShow(id: Int32, completion: @escaping (Show?) -> () = { _ in }) {
        let seriesEndpoint = "https://api.thetvdb.com/series/\(String(id))"
        
        guard let seriesURL = URL(string: seriesEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: seriesURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            print("Getting show with ID: \(id)")
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }

            do {
                dump(String(data: data!, encoding: .utf8))
                let showInfo = try JSONDecoder().decode(API_Show.self, from: responseData).data!
                completion(Show(from: showInfo))
            } catch {
                print(error, error.localizedDescription)
            }
        }.resume()
    }
    
    static func searchShows(show: String, completion: @escaping ([Show]?, String?) -> ()) {
        var searchURL = "https://api.thetvdb.com/search/series?name=\(show)"
        
        if let encoded = searchURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let encodedURL = URL(string: encoded) {
            searchURL = encodedURL.absoluteString
        }
        
        guard let seriesURL = URL(string: searchURL) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: seriesURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // print("ResponseData: \(String(data: responseData, encoding: .utf8))")
            
            do {
                let results = try JSONDecoder().decode(API_SearchResults.self, from: responseData)
                var shows = [Show]()
                
                guard let showsSearched = results.data else {
                    print("No data, returning error")
                    completion(nil, results.Error)
                    return
                }
                
                for show in showsSearched {
                    shows.append(Show(from: show))
                }
                completion(shows, nil)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    static func getEpisodes(show id: Int32, parameters: String? = nil, completion: @escaping ([Episode]?) -> ()) {
        var episodesURLEndpoint = "https://api.thetvdb.com/series/\(id)/episodes"
        let episodeGroup = DispatchGroup()
        
        if let param = parameters {
            episodesURLEndpoint += "/query?\(param)"
        }
        
        guard let episodesURL = URL(string: episodesURLEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: episodesURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            print(response!.url!, response!.StatusCode)
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
                
                let results = try JSONDecoder().decode(API_Episodes.self, from: responseData)
                // dump(results.data)
                
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
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
        
    }
    
    static func getImageURLs(show id: Int32, resolution: Resolution, completion: @escaping (API_Images?) -> () = { _ in }) {
        let imagesURLEndpoint = "https://api.thetvdb.com/series/\(id)/images/query?keyType=fanart&resolution=\(resolution.rawValue)"
        
        guard let episodesURL = URL(string: imagesURLEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: episodesURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                let images = try JSONDecoder().decode(API_Images.self, from: responseData)
                completion(images)
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    static func getEpisodeSummary(show id: Int32, completion: @escaping (EpisodeSummary?) -> ()) {
        let imagesURLEndpoint = "https://api.thetvdb.com/series/\(id)/episodes/summary"
        
        guard let episodesURL = URL(string: imagesURLEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        print(episodesURL)
        
        var request = URLRequest(url: episodesURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // dump(String(data: responseData, encoding: .utf8))
            
            do {
                let summary = try JSONDecoder().decode(API_EpisodeSummary.self, from: responseData)
                completion(EpisodeSummary(airedEpisodes: summary.data?.airedEpisodes, airedSeasons: summary.data?.airedSeasons?.sorted()))
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
}
