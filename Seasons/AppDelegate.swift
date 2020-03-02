//
//  AppDelegate.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 13/1/17.
//  Copyright © 2017 Thomas Greenwood. All rights reserved.
//

import UIKit
import UserNotifications
import BackgroundTasks

let userDefaults = UserDefaults.standard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    static let bgTaskShowUpdate = "com.greeny.Seasons.update"
    static let bgTaskScheduleNotif = "com.greeny.Seasons.schedule"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
        #endif
        
        if (userDefaults.object(forKey: "preferFullHD") == nil) {
            userDefaults.set(false, forKey: "preferFullHD")
        }
        
        if (userDefaults.object(forKey: "preferFullHD") == nil) {
            userDefaults.set(true, forKey: "sendEpisodeNotifications")
        }
        
        if (userDefaults.object(forKey: "firstRun") == nil) {
            print("First run!")
            userDefaults.set(true, forKey: "firstRun")
            userDefaults.set(0, forKey: "theme")
            userDefaults.set(true, forKey: "showUpdateNotification")
            userDefaults.set(false, forKey: "preferFullHD")
            userDefaults.set(true, forKey: "sendEpisodeNotifications")
        } else {
            print("Not first run!")
        }
        
        let theme = userDefaults.integer(forKey: "theme")
        print("Theme is \(theme)")
        
        if (theme == 0) {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
        } else if (theme == 1) {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
        } else if (theme == 2) {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.bgTaskShowUpdate, using: nil) { task in
            self.handleShowUpdate(task: task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.bgTaskScheduleNotif, using: nil) { task in
            self.handleScheduleNotification(task: task as! BGAppRefreshTask)
        }
        
        scheduleNotifications()
        
        window?.backgroundColor = .systemBackground
        
        TVDBAPI.retrieveToken() {
            PersistenceService.updateEpisodes()
        }
        
        return true
    }
    
    // MARK: - Scheduling Tasks
    private func scheduleShowUpdate() {
        let request = BGProcessingTaskRequest(identifier: Self.bgTaskShowUpdate)
        // Perform a background task at earliest after 12 hours
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 12)
        request.requiresNetworkConnectivity = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error, error.localizedDescription)
        }
    }
    
    private func scheduleAiringNotification() {
        let request = BGAppRefreshTaskRequest(identifier: Self.bgTaskScheduleNotif)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch let x as BGTaskScheduler.Error {
            switch x.code {
            case .notPermitted: break
            case .tooManyPendingTaskRequests:
                print("tooManyPendingTaskRequests")
            case .unavailable: break
                
            @unknown default: break
                
            }
        } catch {
            print(error, error.localizedDescription)
        }
    }
    
    // MARK: - Handling Launch for Tasks
    private func handleShowUpdate(task: BGProcessingTask) {
        scheduleShowUpdate()
        
        let api = TVDBAPI_Background()
        api.backgroundTask = task
        api.getToken()
        
        task.expirationHandler = {
            api.downloadTask.cancel()
        }
    }
    
    private func handleScheduleNotification(task: BGAppRefreshTask) {
        scheduleAiringNotification()
        scheduleNotifications()
        
        task.setTaskCompleted(success: true)
        task.expirationHandler = {
            // api.downloadTask.cancel()
        }
    }
    
    private func scheduleNotifications() {
        if (UserDefaults.standard.bool(forKey: "sendEpisodeNotifications")) {
            if let episodes = PersistenceService.getEpisodes(filterUpcoming: true) {
                for episode in episodes {
                    let show = PersistenceService.getShow(id: episode.seriesId!)
                    let airDate = episode.firstAired
                    var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: airDate)
                    dateComponents.hour = 9
                    dateComponents.minute = 0
                    
                    let content = UNMutableNotificationContent()
                    content.title = show?.seriesName ?? "Unknown series"
                    content.body = "\(episode.episodeName ?? "Unknown Episode Name") airing today!"
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: "com.greeny.Seasons.episodeAiring.\(episode.seriesId!).\(episode.id)", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            }
            
            UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                for request in requests {
                    if request.identifier.contains("com.greeny.Seasons") {
                        print(request)
                    }
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        BGTaskScheduler.shared.cancelAllTaskRequests()
        scheduleShowUpdate()
        scheduleAiringNotification()
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    // MARK: - Core Data stack
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        PersistenceService.saveContext()
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("IDENTIFIER: \(identifier)")
        completionHandler()
    }
}
