//
//  TVDBAPI+Background.swift
//  Seasons
//
//  Created by Thomas Greenwood on 22/11/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import UIKit

class TVDBAPI_Background: NSObject, URLSessionTaskDelegate, URLSessionDelegate, URLSessionDataDelegate {
    
    static var currentToken: String = ""
    
    static var backgroundURLSession: URLSession {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.greeny.Seasons.update")
        configuration.isDiscretionary = true
        configuration.timeoutIntervalForRequest = 30

        return URLSession(configuration: configuration, delegate: TVDBAPI_Background(), delegateQueue: nil)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if (dataTask.originalRequest?.url?.absoluteString == "https://api.thetvdb.com/login") {
            do {
                let auth = try JSONDecoder().decode(API_Authentication.self, from: data)
                
                if let token = auth.token {
                    TVDBAPI_Background.currentToken = token
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Background App Refresh"
                    content.subtitle = "Running token task..."
                    content.body = "Token set to: \(token)"

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
                    let request = UNNotificationRequest(identifier: "local_notification", content: content, trigger: trigger)

                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
    }
        
    static func retrieveToken() {
        // TODO: If token is expired (check status code/error) renew it
        let params = ["apikey" : APIKey]
        // FIXME: Proper error handling?
        let json = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let endpoint = URL(string: "https://api.thetvdb.com/login")
        
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.httpBody = json
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        backgroundURLSession.dataTask(with: request).resume()
        
    }
    
}
