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
    }
    
    private static var currentToken: String = ""
    
    /// Retrieves a token from thetvdb.com
    ///
    /// - Parameters:
    ///   - key: API Key given by your account on thetvdb.com
    ///   - success: Callback after retrieval.
    ///   - error: A (hopefully) descriptive error if no data is retrieved, if JSON decoding goes wrong or an API error from thetvdb.com.
    
    static func retrieveToken(completion: @escaping (Error) -> () = { _ in }) {
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
                completion(error!)
                return
            }
            
            print("Status Code: \(response!.StatusCode)")
            
            do {
                let auth = try JSONDecoder().decode(Authentication.self, from: data)
                
                if let token = auth.token {
                    currentToken = token
                    print("Token set to:", token)
                }
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    static func getDetailsOfShow(id: Int, using token: String, completion: @escaping (Show) -> () = { _ in }) {
        let seriesEndpoint = "https://api.thetvdb.com/series/\(String(id))/filter?keys=seriesName%2Coverview%2Cid"
        
        guard let seriesURL = URL(string: seriesEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: seriesURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
                let showInfo = try JSONDecoder().decode(Show.self, from: responseData)
                completion(showInfo)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    static func searchSeries(series: String, completion: @escaping (SearchResults?) -> ()) {
        let searchURL = "https://api.thetvdb.com/search/series?name=" + series.replacingOccurrences(of: " ", with: "%20")
        
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
            
            do {
                let results = try JSONDecoder().decode(SearchResults.self, from: responseData)
                completion(results)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    static func getEpisodes(show id: Int, completion: @escaping ([Episodes.Data]?) -> ()) {
        let episodesURLEndpoint = "https://api.thetvdb.com/series/\(id)/episodes"
        
        guard let episodesURL = URL(string: episodesURLEndpoint) else {
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
                let results = try JSONDecoder().decode(Episodes.self, from: responseData)
                completion(results.data)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
        
    }
    
    static func getImages(show id: Int, resolution: Resolution, completion: @escaping (Images?) -> () = { _ in }) {
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
                let images = try JSONDecoder().decode(Images.self, from: responseData)
                completion(images)
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
}
