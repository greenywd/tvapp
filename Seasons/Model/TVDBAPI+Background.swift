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

class TVDBAPI_Background: NSObject {
    lazy var backgroundURLSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.greeny.Seasons.getToken")
        configuration.isDiscretionary = true
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 10
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    static var currentToken: String = "" {
        didSet {
            
        }
    }
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundTask: BGAppRefreshTask!
    
    func updateShows(task: BGAppRefreshTask) {
        // TODO: If token is expired (check status code/error) renew it
        let params = ["apikey" : APIKey]
        // FIXME: Proper error handling?
        let json = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        let endpoint = URL(string: "https://api.thetvdb.com/login")
        
        var request = URLRequest(url: endpoint!)
        request.httpMethod = "POST"
        request.httpBody = json
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        self.downloadTask = backgroundURLSession.downloadTask(with: request)
    }
}

extension TVDBAPI_Background : URLSessionDelegate {
    
}

extension TVDBAPI_Background : URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("\(downloadTask.taskIdentifier), \(String(data: try! Data(contentsOf: location), encoding: .utf8)!)")
        
        let content = UNMutableNotificationContent()
        content.title = "Background App Refresh"
        content.subtitle = "Token task"
        content.body = "\(String(data: try! Data(contentsOf: location), encoding: .utf8)!)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: "com.greeny.Seasons.tokenTask", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        self.backgroundTask.setTaskCompleted(success: true)
    }
}

//extension TVDBAPI_Background : URLSessionTaskDelegate, URLSessionDelegate, URLSessionDataDelegate {
//
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        if (dataTask.originalRequest?.url?.absoluteString == "https://api.thetvdb.com/login") {
//            do {
//                let auth = try JSONDecoder().decode(API_Authentication.self, from: data)
//
//                if let token = auth.token {
//                    TVDBAPI_Background.currentToken = token
//
//                    let content = UNMutableNotificationContent()
//                    content.title = "Background App Refresh"
//                    content.subtitle = "Token task"
//                    content.body = "Token: \(token)"
//
//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
//                    let request = UNNotificationRequest(identifier: "com.greeny.Seasons.tokenTask", content: content, trigger: trigger)
//                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//
//                    let favouriteShowIDs = PersistenceService.getShowIDs()
//
//                    for id in favouriteShowIDs {
//                        let seriesURL = URL(string: "https://api.thetvdb.com/series/\(String(id))")
//
//                        var request = URLRequest(url: seriesURL!)
//                        request.httpMethod = "GET"
//                        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//                        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//                        let api = TVDBAPI_Background()
//                        api.backgroundURLSession.dataTask(with: request).resume()
//                    }
//                }
//
//            } catch {
//                print(error, error.localizedDescription)
//            }
//        } else if (dataTask.originalRequest?.url?.absoluteString.contains("https://api.thetvdb.com/series/") ?? false) {
//            do {
//                let show = try JSONDecoder().decode(API_Show.self, from: data).data
//
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CD_Show")
//                fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: show!.id))
//
//                let CDShow = try! PersistenceService.context.fetch(fetchRequest)
//                let obj = CDShow[0] as! NSManagedObject
//
//                obj.setValue(show?.banner, forKey: "banner")
//                obj.setValue(show?.id, forKey: "id")
//                obj.setValue(show?.network, forKey: "network")
//                obj.setValue(show?.overview, forKey: "overview")
//                obj.setValue(show?.runtime, forKey: "runtime")
//                obj.setValue(show?.seriesName, forKey: "seriesName")
//                obj.setValue(show?.siteRating, forKey: "siteRating")
//                obj.setValue(show?.siteRatingCount, forKey: "siteRatingCount")
//                obj.setValue(show?.status, forKey: "status")
//
//                PersistenceService.saveContext()
//
//                let content = UNMutableNotificationContent()
//                content.title = "Background App Refresh"
//                content.subtitle = "Show task"
//                content.body = "Updated \(show?.seriesName)"
//
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
//                let request = UNNotificationRequest(identifier: "com.greeny.Seasons.showUpdatedNotification", content: content, trigger: trigger)
//
//                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//            } catch {
//                print(error, error.localizedDescription)
//            }
//        }
//    }
//}
