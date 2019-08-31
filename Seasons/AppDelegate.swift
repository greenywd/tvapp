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
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
        #endif
        
        if (userDefaults.object(forKey: "preferFullHD") == nil) {
            userDefaults.set(false, forKey: "preferFullHD")
        }
        
        if (userDefaults.object(forKey: "firstRun") == nil) {
            print("First run!")
            userDefaults.set(true, forKey: "firstRun")
            userDefaults.set(0, forKey: "theme")
            userDefaults.set(true, forKey: "showUpdateNotification")
            userDefaults.set(false, forKey: "preferFullHD")
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
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (allowed, error) in
            if (!allowed) {
                print("Declined Notifications")
            }
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.greeny.Seasons.update", using: DispatchQueue.global()) { task in
            self.fireLocalNotification()
            self.handleShowUpdate(task as! BGAppRefreshTask)
        }
        
        window?.backgroundColor = .systemBackground
        TVDBAPI.retrieveToken()
        
        return true
    }
    
    private func fireLocalNotification(content: UNMutableNotificationContent? = nil) {
        if content == nil {
            let content = UNMutableNotificationContent()
            content.title = "Background Refresh"
            content.body = "You see this? Let me know!"
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: "local_notification", content: content!, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func scheduleShowUpdate() {
        do {
            let request = BGAppRefreshTaskRequest(identifier: "com.greeny.Seasons.update")
            
            request.earliestBeginDate = Date(timeIntervalSinceNow: 1800)
            
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error, error.localizedDescription)
        }
    }
    
    private func handleShowUpdate(_ task: BGAppRefreshTask) {
        PersistenceService.updateShows { shows in
            if shows.contains(where: { (key, value) -> Bool in
                value == true
            }) {
                let content = UNMutableNotificationContent()
                content.title = "Favourites Updated"
                content.body = "You see this? Let me know!"
                
                fireLocalNotification(content: content)
            }
            fireLocalNotification()
        }
        
        task.expirationHandler = {
            // TODO: Cancel network requests
        }
        
        task.setTaskCompleted(success: true)
    }
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // BGTaskScheduler.shared.cancelAllTaskRequests()
        scheduleShowUpdate()
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
}

