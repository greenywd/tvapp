//
//  TVDBAPI.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 28/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import Foundation

protocol TVDBError : Error {
    var title: String { get }
}

class TVDBAPI {
    
    struct Authentication : Codable {
        let token: String?
        fileprivate let Error: String?
    }
    
    struct TVError : TVDBError {
        var title: String
        
        init(title: String) {
            self.title = title
        }
    }
    
    struct Episodes : Codable {
        let data: [Data]?
        
        struct Data : Codable {
            let airedEpisodeNumber: Int
            let overview: String?
            let guestStars: [String]
            let id: Int
            let imdbId: String
            let filename: String
            let director: String
            let airedSeason: Int
            // let siteRating: Double
            let episodeName: String
            // let writers: [String]
            // let directors: [String]
            let seriesId: Int
            let firstAired: String
        }
    }
    
    static var token: String = "aaa you shouldn't be seeing this!"
    
    /// Retrieves a token from thetvdb.com
    ///
    /// - Parameters:
    ///   - key: API Key given by your account on thetvdb.com
    ///   - success: Callback after retrieval.
    ///   - auth: Authentication struct which will contain a token provided by thetvdb.com.
    ///   - error: A (hopefully) descriptive error if no data is retrieved, if JSON decoding goes wrong or an API error from thetvdb.com.
    
    func retrieveToken(using key: String = "BE5F53398FC1FB01", completion: @escaping (Error) -> () = { _ in }) {
        // TODO: If token is expired (check status code/error) renew it
        print("hell yeah brother lets retrieve a token")
        let params = ["apikey" : key]
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
                    TVDBAPI.token = token
                    print("Token set to:", token)
                }
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    
    func getDetailsOfShow(id: Int, using token: String, completion: @escaping (ShowJSON) -> () = { _ in }) {
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
                let showInfo = try JSONDecoder().decode(ShowJSON.self, from: responseData)
                completion(showInfo)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    func searchSeries(series: String, using token: String, completion: @escaping (SearchResults?) -> ()) {
        let searchURL = "https://api.thetvdb.com/search/series?name=" + series.replacingOccurrences(of: " ", with: "%20")
        
        guard let seriesURL = URL(string: searchURL) else {
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
                let results = try JSONDecoder().decode(SearchResults.self, from: responseData)
                completion(results)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
    
    func getEpisodes(show id: Int, using token: String, completion: @escaping (Episodes?) -> ()) {
        let episodesURLEndpoint = "https://api.thetvdb.com/series/\(id)/episodes"
        
        guard let episodesURL = URL(string: episodesURLEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: episodesURL)
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
                let results = try JSONDecoder().decode(Episodes.self, from: responseData)
                completion(results)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
        
    }
}
