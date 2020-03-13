//
//  TVDBAPI+Background.swift
//  Seasons
//
//  Created by Thomas Greenwood on 22/11/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import CoreData
import UserNotifications
import BackgroundTasks
import os

class TVDBAPI_Background: NSObject {
    private func createBackgroundURLSession(identifier: String) -> URLSession {
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        configuration.isDiscretionary = true
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    static var token: String = ""
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundTask: BGProcessingTask!
    private var lastShowID: Int32!
    
    func getToken() {
        // TODO: If token is expired (check status code/error) renew it
        let params = ["apikey" : TVDBAPIKey]
        // FIXME: Proper error handling?
        let json = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let endpoint = URL(string: "https://api.thetvdb.com/login")
        
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.httpBody = json
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        self.downloadTask = createBackgroundURLSession(identifier: "com.greeny.Seasons.getToken").downloadTask(with: request)
        self.downloadTask.resume()
    }
    
    func updateShows() {
        let favouriteShowIDs = PersistenceService.getShowIDs()
        self.lastShowID = favouriteShowIDs.last!
        
        for id in favouriteShowIDs {
            let seriesURL = URL(string: "https://api.thetvdb.com/series/\(String(id))")
            
            var request = URLRequest(url: seriesURL!)
            request.httpMethod = "GET"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(TVDBAPI_Background.token)", forHTTPHeaderField: "Authorization")
            self.downloadTask = createBackgroundURLSession(identifier: "com.greeny.Seasons.updateShows.\(id)").downloadTask(with: request)
            self.downloadTask.resume()
        }
    }
}

extension TVDBAPI_Background : URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if (session.configuration.identifier == "com.greeny.Seasons.getToken") {
            do {
                TVDBAPI_Background.token = try JSONDecoder().decode(API_Authentication.self, from: Data(contentsOf: location)).token!
                updateShows()
            } catch {
                os_log("Failed to decode response for token with %@.", log: .networking, type: .error, error.localizedDescription)
            }

        } else if (session.configuration.identifier!.contains("com.greeny.Seasons.updateShows")) {
            do {
                let data = try Data(contentsOf: location)
                let show = try JSONDecoder().decode(RawShowResponse.self, from: data).data
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CD_Show")
                fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: show!.id))
                
                let CDShow = try! PersistenceService.context.fetch(fetchRequest)
                let obj = CDShow.first as! NSManagedObject
                
                obj.setValue(show?.banner, forKey: "banner")
                obj.setValue(show?.id, forKey: "id")
                obj.setValue(show?.network, forKey: "network")
                obj.setValue(show?.overview, forKey: "overview")
                obj.setValue(show?.runtime, forKey: "runtime")
                obj.setValue(show?.seriesName, forKey: "seriesName")
                obj.setValue(show?.siteRating, forKey: "siteRating")
                obj.setValue(show?.siteRatingCount, forKey: "siteRatingCount")
                obj.setValue(show?.status, forKey: "status")
                
                if (show?.id == lastShowID) {
                    PersistenceService.saveContext()
                    self.backgroundTask.setTaskCompleted(success: true)
                }
                
            } catch {
                os_log("Failed to decode show data with %@.", log: .networking, type: .error, error.localizedDescription)
            }
        }
    }
}
