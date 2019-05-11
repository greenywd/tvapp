import Foundation
import UIKit

var artwork: UIImage?

//struct Episode {
//    let name: String
//    let season: Int
//    let episode: Int
//    let overview: String?
//    let id: Int
//}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct HTTPHeader {
    let field: String
    let value: String
}

//fileprivate struct Season {
//    let number: Int
//    let episodes: [Episode]
//}

struct Show : Codable {
    var Error: String?
    let data: Data?
    
    struct Data : Codable {
        let id: Int
        let overview: String
        let seriesName: String
    }
}

struct Authentication : Codable {
    let token: String?
    fileprivate let Error: String?
}

protocol TVDBError : Error {
    var title: String { get }
    var code: Int { get }
}

struct TVError : TVDBError {
    var title: String
    var code: Int
    
    init(title: String, code: Int) {
        self.title = title
        self.code = code
    }
}

struct SearchResults : Codable {
    let data: [Data]?
    
    struct Data : Codable {
        let aliases: [String]
        let banner: String
        let firstAired: String
        let id: Int
        let network: String
        let overview: String
        let seriesName: String
        let status: String
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

extension URLResponse {
    func statusCode() -> Int {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return -1
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}


// let imageEndpoint = "https://api.thetvdb.com/series/\(String(id))/images/query?keyType=fanart&resolution=1280x720"

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
        
        // print(String(data: responseData, encoding: .utf8)!)
        do {
            let results = try JSONDecoder().decode(SearchResults.self, from: responseData)
            completion(results)
        } catch {
            print(error, error.localizedDescription)
        }
    }
    showTask.resume()
}

func retrieveToken(using key: String = "BE5F53398FC1FB01", completion: @escaping (_ auth: Authentication?, _ error: Error?) -> ()) {
    let params = ["apikey" : key]
    let json = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
    
    let endpoint = URL(string: "https://api.thetvdb.com/login")
    
    var request = URLRequest(url: endpoint!)
    request.httpMethod = "POST"
    request.httpBody = json
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
    print(String(data: request.httpBody!, encoding: .utf8)!)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil, error)
            return
        }
        
        do {
            let auth = try JSONDecoder().decode(Authentication.self, from: data)
            
            if let msg = auth.Error {
                throw TVError(title: msg, code: -1)
            }
            
            completion(auth, nil)
            
        } catch {
            completion(nil, error)
        }
    }
    
    task.resume()
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

retrieveToken(completion: { (auth, error) in
    if let auth = auth?.token {
        print(auth)
    }
})
