//
//  PersistenceService.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 15/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import os

class PersistenceService {
    
    private static let showEntity = "Show"
    private static let episodeEntity = "Episode"
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var temporaryContext: NSManagedObjectContext = {
        let temporaryContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        temporaryContext.parent = PersistenceService.context
        return temporaryContext
    }()
    
    static var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "Seasons")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()
    
    static func newBackgroundContext() -> NSManagedObjectContext {
        let context = self.persistentContainer.newBackgroundContext()
        context.parent = self.context
        return context
    }
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                os_log("Saved context.", log: .coredata)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    /// Determines whether a `Show`s `id` exists in CoreData.
    /// - Parameter id: The `id` of the `Show` to check.
    static func showExists(id: Int32) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: showEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try self.context.count(for: fetchRequest)
        }
        catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        assert(entitiesCount <= 1, "Expected either 0 or 1. Got \(entitiesCount) instead.")
        return entitiesCount > 0
    }
    
    /// Delete an entity (`Show`) using a specified `id`.
    /// - Parameter id: The `id` of the `Show` to be deleted.
    static func deleteShow(id: Int32) {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: showEntity)
            fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
            
            let shows = try self.context.fetch(fetchRequest)
            self.context.delete(shows.first as! NSManagedObject)
            
            removeScheduledNotifications(for: id)
            
            self.saveContext()
            
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
    }
    
    /// Delete all episodes related to a `Show` using a specified show's `id`.
    /// - Parameter id: The `id` of the `Show` to be deleted.
    static func deleteEpisodesForShow(id: Int32) {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
            fetchRequest.predicate = NSPredicate(format: "seriesId = %@", NSNumber(value: id))
            
            let episodes = try self.context.fetch(fetchRequest)
            for episode in episodes {
                self.context.delete(episode as! NSManagedObject)
            }
            PersistenceService.saveContext()
            
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
    }
    
    static func markEpisode(id: Int32, watched: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
                fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
                
                let episode = try self.context.fetch(fetchRequest).first as! Episode

                episode.hasWatched = watched
                PersistenceService.saveContext()
                
            } catch {
                os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
            }
        }
    }
    
    static func markEpisodes(ids: [Int32], watched: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            for id in ids {
                do {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
                    fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
                    
                    let episode = try self.context.fetch(fetchRequest).first as! Episode

                    episode.hasWatched = watched
                    PersistenceService.saveContext()
                    
                } catch {
                    os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
                }
            }
        }
    }
    
    static func markEpisodes(for showID: Int32, inSeason airedSeason: Int16, watched: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
                
                let seriesIDPredicate = NSPredicate(format: "showID = %@", NSNumber(value: showID))
                let airedSeasonPredicate = NSPredicate(format: "seasonNumber = %@", NSNumber(value: airedSeason))
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [seriesIDPredicate, airedSeasonPredicate])
                
                let episode = try PersistenceService.context.fetch(fetchRequest) as! [Episode]
                
                for ep in episode {
                    ep.hasWatched = watched
                }
                
                PersistenceService.saveContext()
                
            } catch {
                os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
            }
        }
    }
    
    static func markEpisodes(for showID: Int32, watched: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
                fetchRequest.predicate = NSPredicate(format: "showID = %@", NSNumber(value: showID))
                
                let episode = try PersistenceService.context.fetch(fetchRequest) as! [Episode]
                
                for ep in episode {
                    ep.hasWatched = watched
                }
                
                PersistenceService.saveContext()
                
            } catch {
                os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
            }
        }
    }
    
    static func markAllEpisodes(watched: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
                
                let episode = try PersistenceService.context.fetch(fetchRequest).first as! NSManagedObject

                episode.setValue(watched, forKey: "hasWatched")
                PersistenceService.saveContext()
                
            } catch {
                os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
            }
        }
    }
    
    /// Retrieve all `Show`s from CoreData.
    static func getShows() -> [Show]? {
        var favouriteShows = [Show]()
        
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        do {
            let shows = try self.context.fetch(fetchRequest)
            
            if shows.count == 0 {
                return nil
            }
            
            for show in shows {
                favouriteShows.append(show)
            }
            
            os_log("Got %d shows for fetch request %@.", log: .coredata, shows.count, #function)
            
            return favouriteShows
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        
        return nil
    }
    
    /// Retrieve all `id`s of `Show`s.
    static func getShowIDs() -> [Int32] {
        var ids = [Int32]()
        
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        do {
            let cIDs = try PersistenceService.context.fetch(fetchRequest)
            
            for id in cIDs {
                ids.append(id.id)
            }
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        
        return ids
    }
    
    /// Retrieve a `Show` using its `id` from CoreData.
    /// - Parameter id: The `id` of the Show.
    static func getShow(id: Int32) -> Show? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: showEntity)
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        
        var favouriteShow: Show?
        
        do {
            let result = try self.context.fetch(fetchRequest)
            assert(result.count <= 1, "Expected either 0 or 1. Got \(result.count) instead.")
            for show in result as! [Show] {
                favouriteShow = show
            }
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        
        return favouriteShow
    }
    
    /// Retrieve all Episodes for a specific Show from CoreData.
    /// - Parameter id: Identifier of the `Show` that Episodes are retrieved from.
    static func getEpisodes(show id: Int32) -> [Episode]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
        fetchRequest.predicate = NSPredicate(format: "seriesId = %@", NSNumber(value: id))
        
        var episodes = [Episode]()
        
        do {
            let result = try self.context.fetch(fetchRequest)
            os_log("Got %d episodes for fetch request %@.", log: .coredata, result.count, #function)
            
            if result.count == 0 {
                return nil
            }
            
            for ep in result as! [Episode] {
                episodes.append(ep)
            }
            
            return episodes
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        return nil
    }
    
    static func getEpisodes(show id: Int32, season airedSeason: Int16) -> [Episode]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
        
        let showIDPredicate = NSPredicate(format: "showID = %@", NSNumber(value: id))
        let airedSeasonPredicate = NSPredicate(format: "seasonNumber = %@", NSNumber(value: airedSeason))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [showIDPredicate, airedSeasonPredicate])
        
        var episodes = [Episode]()
        
        do {
            let result = try self.context.fetch(fetchRequest)
            os_log("Got %d episodes for fetch request %@.", log: .coredata, result.count, #function)
            
            if result.count == 0 {
                return nil
            }
            
            for ep in result as! [Episode] {
                episodes.append(ep)
            }
            
            return episodes
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        return nil
    }
    
    /// Get all episodes for all shows
    static func getEpisodes(filterUnwatched: Bool? = false, filterUpcoming: Bool? = true) -> [Episode]? {
        var episodes = [Episode]()
        
        let fetchRequest: NSFetchRequest<Episode> = Episode.fetchRequest()
        let sortAirDate = NSSortDescriptor(key: #keyPath(Episode.airDate), ascending: true)
        
        if (filterUnwatched == true && filterUpcoming == true) {
            let hasWatchedPredicate = NSPredicate(format: "hasWatched == %@", NSNumber(value: false))
            let isUpcomingPredicate = NSPredicate(format: "airDate >= %@", Date() as NSDate)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [hasWatchedPredicate, isUpcomingPredicate])
        } else if (filterUnwatched == true && filterUpcoming == false) {
            fetchRequest.predicate = NSPredicate(format: "hasWatched == %@", NSNumber(value: false))
        } else if (filterUnwatched == false && filterUpcoming == true) {
            fetchRequest.predicate = NSPredicate(format: "airDate >= %@", Date() as NSDate)
        }
        
        fetchRequest.sortDescriptors = [sortAirDate]
        do {
            let result = try self.context.fetch(fetchRequest)
            os_log("Got %d episodes for fetch request %@.", log: .coredata, result.count, #function)
            
            if result.count == 0 {
                return nil
            }
            
            for ep in result {
                episodes.append(ep)
            }
            
            return episodes
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        return nil
    }
    
    /// Retrieve all Episodes for a list of Shows from CoreData.
    /// - Parameter ids: Identifier(s) of `Show`s that Episodes are retrieved from.
    static func getEpisodes(show ids: [Int32]) -> [Episode]? {
        var episodes = [Episode]()
        
        for id in ids {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
            fetchRequest.predicate = NSPredicate(format: "seriesId = %@", NSNumber(value: id))
            
            do {
                let result = try self.context.fetch(fetchRequest)
                
                for ep in result as! [Episode] {
                    episodes.append(ep)
                }
            } catch {
                os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
            }
        }
        return episodes.isEmpty ? nil : episodes
    }
    
    /// Force update all favourite shows
    /// - Parameter completion:
    static func updateShows(completion: ([Int32 : Bool]) -> () = {_ in }) {
        var updatedShows = [Int32 : Bool]()
        if let favouriteShows = self.getShows() {
            let ids = favouriteShows.map { $0.id }
            
            for id in ids {
                TMDBAPI.getShow(id: id) { (show) in
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CD_Show")
                    fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
                    
                    let CDShow = try! self.context.fetch(fetchRequest)
                    let show = CDShow[0] as! Show
                    
                    // TODO: Add Show info
                    
                    
                    updatedShows[id] = show.changedValues().isEmpty
                    self.saveContext()
                }
            }
            completion(updatedShows)
        }
    }
    
    /// Force update all episodes of favourite shows
    /// - Parameter completion: <#completion description#>
    static func updateEpisodes(completion: ([Int32 : Bool]) -> () = {_ in}) {
        // Get all current favourite shows' IDs
        if let favouriteShows = self.getShows() {
            // Create an array of all IDs
            let ids = favouriteShows.map { $0.id }
            
            for id in ids {
                // For each episode, make an API call
                let currentShow = favouriteShows.first(where: { $0.id == id })!
                for season in currentShow.seasons! as! Set<Season> {
                    TMDBAPI.getEpisodes(show: id, season: season.seasonNumber) { (episodes) in
                        if let unwrappedEpisodes = episodes {
                            season.addToEpisodes(NSSet(array: unwrappedEpisodes))
                        }
                    }
                }
            }
        }
    }
    
    static func removeScheduledNotifications(for id: Int32? = nil) {
        if let id = id {
            var notifications = [String]()
            UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                for request in requests {
                    if (request.identifier.contains("com.greeny.Seasons.episodeAiring.\(id)")) {
                        notifications.append(request.identifier)
                    }
                }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notifications)
            }
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// For debugging purposes, delete EVERYTHING.
    static func dropTable() {
        // Wait, this isn't SQL.
        
        if let favouriteShows = self.getShows() {
            let ids = favouriteShows.map { $0.id }
            
            for id in ids {
                self.deleteEpisodesForShow(id: id)
                self.deleteShow(id: id)
            }
        }
    }
}
