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
    
    private static let showEntity = "CD_Show"
    private static let episodeEntity = "CD_Episode"
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
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
            
            let shows = try PersistenceService.context.fetch(fetchRequest)
            PersistenceService.context.delete(shows.first as! NSManagedObject)
            
            removeScheduledNotifications(for: id)
            
            PersistenceService.saveContext()
            
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
            
            let episodes = try PersistenceService.context.fetch(fetchRequest)
            for episode in episodes {
                PersistenceService.context.delete(episode as! NSManagedObject)
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
                
                let episode = try PersistenceService.context.fetch(fetchRequest).first as! NSManagedObject
                dump(episode)
                episode.setValue(watched, forKey: "hasWatched")
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
                    
                    let episode = try PersistenceService.context.fetch(fetchRequest).first as! NSManagedObject
                    dump(episode)
                    episode.setValue(watched, forKey: "hasWatched")
                    PersistenceService.saveContext()
                    
                } catch {
                    os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
                }
            }
        }
    }
    
    static func markEpisodes(for showID: Int32, inSeason airedSeason: Int32, watched: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
                
                let seriesIDPredicate = NSPredicate(format: "seriesId = %@", NSNumber(value: showID))
                let airedSeasonPredicate = NSPredicate(format: "airedSeason = %@", NSNumber(value: airedSeason))
                fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [seriesIDPredicate, airedSeasonPredicate])
                
                let episode = try PersistenceService.context.fetch(fetchRequest) as! [NSManagedObject]
                
                for ep in episode {
                    ep.setValue(watched, forKey: "hasWatched")
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
                fetchRequest.predicate = NSPredicate(format: "seriesId = %@", NSNumber(value: showID))
                
                let episode = try PersistenceService.context.fetch(fetchRequest) as! [NSManagedObject]
                
                for ep in episode {
                    ep.setValue(watched, forKey: "hasWatched")
                }

                PersistenceService.saveContext()
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
    }
    
    static func markAllEpisodes(watched: Bool) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
                
                let episode = try PersistenceService.context.fetch(fetchRequest).first as! NSManagedObject
                dump(episode)
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
        
        let fetchRequest: NSFetchRequest<CD_Show> = CD_Show.fetchRequest()
        do {
            let shows = try PersistenceService.context.fetch(fetchRequest)
            
            if shows.count == 0 {
                return nil
            }
            
            for show in shows {
                favouriteShows.append(Show(from: show))
            }
            
            return favouriteShows
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        
        return nil
    }
    
    /// Retrieve all `id`s of `Show`s.
    static func getShowIDs() -> [Int32] {
        var ids = [Int32]()
        
        let fetchRequest: NSFetchRequest<CD_Show> = CD_Show.fetchRequest()
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
        
        var show: Show?
        
        do {
            let result = try self.context.fetch(fetchRequest)
            
            for data in result as! [CD_Show] {
                show = Show(from: data)
            }
        }
        catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        
        return show
    }
    
    /// Retrieve all Episodes for a specific Show from CoreData.
    /// - Parameter id: Identifier of the `Show` that Episodes are retrieved from.
    static func getEpisodes(show id: Int32) -> [Episode]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
        fetchRequest.predicate = NSPredicate(format: "seriesId = %@", NSNumber(value: id))
        
        var episodes = [Episode]()
        
        do {
            let result = try self.context.fetch(fetchRequest)
            print("Got \(result.count) episodes")
            
            if result.count == 0 {
                return nil
            }
            
            for ep in result as! [CD_Episode] {
                episodes.append(Episode(from: ep))
            }
            
            return episodes
        } catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        return nil
    }
    
    static func getEpisodes(show id: Int32, season airedSeason: Int32) -> [Episode]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: episodeEntity)
        
        let showIDPredicate = NSPredicate(format: "seriesId = %@", NSNumber(value: id))
        let airedSeasonPredicate = NSPredicate(format: "airedSeason = %@", NSNumber(value: airedSeason))
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [showIDPredicate, airedSeasonPredicate])
        
        var episodes = [Episode]()
        
        do {
            let result = try self.context.fetch(fetchRequest)
            os_log("Got %d episodes for fetch request %@.", log: .coredata, result.count, #function)
            
            if result.count == 0 {
                return nil
            }
            
            for ep in result as! [CD_Episode] {
                episodes.append(Episode(from: ep))
            }
            
            return episodes
        }
        catch {
            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
        }
        return nil
    }
    
    /// Get all episodes for all shows
    static func getEpisodes(filterUnwatched: Bool? = false, filterUpcoming: Bool? = true) -> [Episode]? {
        var episodes = [Episode]()
        
        let fetchRequest: NSFetchRequest<CD_Episode> = CD_Episode.fetchRequest()
        let sortAirDate = NSSortDescriptor(key: #keyPath(CD_Episode.firstAired), ascending: true)
        
        if (filterUnwatched == true && filterUpcoming == true) {
            let hasWatchedPredicate = NSPredicate(format: "hasWatched == %@", NSNumber(value: false))
            let isUpcomingPredicate = NSPredicate(format: "firstAired >= %@", Date() as NSDate)
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [hasWatchedPredicate, isUpcomingPredicate])
        } else if (filterUnwatched == true && filterUpcoming == false) {
            fetchRequest.predicate = NSPredicate(format: "hasWatched == %@", NSNumber(value: false))
        } else if (filterUnwatched == false && filterUpcoming == true) {
            fetchRequest.predicate = NSPredicate(format: "firstAired >= %@", Date() as NSDate)
        }

        fetchRequest.sortDescriptors = [sortAirDate]
        do {
            let result = try self.context.fetch(fetchRequest)
            print("Got \(result.count) episodes")
            
            if result.count == 0 {
                return nil
            }
            
            for ep in result {
                episodes.append(Episode(from: ep))
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
                
                for ep in result as! [CD_Episode] {
                    episodes.append(Episode(id: ep.id, overview: ep.overview, airedEpisodeNumber: ep.airedEpisodeNumber, airedSeason: ep.airedSeason, episodeName: ep.episodeName, firstAired: ep.firstAired, filename: ep.filename, seriesId: ep.seriesId, hasWatched: ep.hasWatched))
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
                TVDBAPI.getShow(id: id) { (show) in
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CD_Show")
                    fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
                    
                    let CDShow = try! self.context.fetch(fetchRequest)
                    let obj = CDShow[0] as! NSManagedObject

                    obj.setValue(show?.banner, forKey: "banner")
                    obj.setValue(show?.id, forKey: "id")
                    obj.setValue(show?.network, forKey: "network")
                    obj.setValue(show?.overview, forKey: "overview")
                    obj.setValue(show?.runtime, forKey: "runtime")
                    obj.setValue(show?.seriesName, forKey: "seriesName")
                    obj.setValue(show?.siteRating, forKey: "siteRating")
                    obj.setValue(show?.siteRatingCount, forKey: "siteRatingCount")
                    obj.setValue(show?.status, forKey: "status")
                    
                    updatedShows[id] = obj.changedValues().isEmpty
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
                TVDBAPI.getEpisodes(show: id) { (episodes) in
                    for ep in episodes! {
                        // For each episode retrieved, setup a fetchRequest to retrieve an existing episode with an episode ID
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CD_Episode")
                        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: ep.id))
                        
                        do {
                            let CDEpisode = try self.context.fetch(fetchRequest)
                            
                            // If we find no episodes, we create one and add it to the current show
                            // This can happen when new episodes are added while a show is favourited
                            // If the episode already exists, overwrite it's contents with the data from the API call
                            if (CDEpisode.count) == 0 {
                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CD_Show")
                                fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
                                
                                let CDShow = try self.context.fetch(fetchRequest)
                                let show = CDShow[0] as! CD_Show
                                
                                let episode = CD_Episode(context: PersistenceService.context)
                                
                                episode.airedEpisodeNumber = ep.airedEpisodeNumber!
                                episode.airedSeason = ep.airedSeason!
                                episode.episodeName = ep.episodeName
                                episode.filename = ep.filename
                                episode.firstAired = ep.firstAired
                                episode.id = ep.id
                                episode.overview = ep.overview
                                episode.seriesId = ep.seriesId!
                                
                                show.addToEpisode(episode)

                            } else {
                                let episode = CDEpisode[0] as! CD_Episode
                                
                                episode.airedEpisodeNumber = ep.airedEpisodeNumber!
                                episode.airedSeason = ep.airedSeason!
                                episode.episodeName = ep.episodeName
                                episode.filename = ep.filename
                                episode.firstAired = ep.firstAired
                                episode.id = ep.id
                                episode.overview = ep.overview
                                episode.seriesId = ep.seriesId!
                            }
                            
                        } catch {
                            os_log("Failed to execute the fetch request (%@) with %@.", log: .coredata, type: .error, #function , error.localizedDescription)
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
