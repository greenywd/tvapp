//
//  PersistenceService.swift
//  Watchlist
//
//  Created by Thomas Greenwood on 15/5/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {
    
    private static let showEntity = "CD_Show"
    private static let episodeEntity = "CD_Episode"
    
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */

        let container = NSPersistentContainer(name: "Seasons")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Saved context.")
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
            print("error executing fetch request: \(error)")
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
            PersistenceService.saveContext()
            
        } catch {
            print(error, error.localizedDescription)
        }
    }
    
    /// Retrieve all `Show`s from CoreData.
    static func getShows() -> [Show] {
        var favouriteShows = [Show]()
        
        let fetchRequest: NSFetchRequest<CD_Show> = CD_Show.fetchRequest()
        do {
            let shows = try PersistenceService.context.fetch(fetchRequest)
            
            for show in shows {
                favouriteShows.append(Show(id: show.id, overview: show.overview, seriesName: show.seriesName, banner: show.banner ?? "", bannerImage: show.bannerImage, status: show.status ?? "Unknown", runtime: show.runtime ?? "Unknown", network: show.network ?? "Unknown", siteRating: show.siteRating, siteRatingCount: show.siteRatingCount))
            }
        } catch {
            print(error, error.localizedDescription)
        }
        
        return favouriteShows
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
            print(error, error.localizedDescription)
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
                show = Show(id: data.id, overview: data.overview, seriesName: data.seriesName, banner: data.banner, bannerImage: data.bannerImage, status: data.status, runtime: data.runtime, network: data.network, siteRating: data.siteRating, siteRatingCount: data.siteRatingCount)
            }
        }
        catch {
            print("error executing fetch request: \(error)")
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
            
            for ep in result as! [CD_Episode] {
                episodes.append(Episode(id: ep.id, overview: ep.overview, airedEpisodeNumber: ep.airedEpisodeNumber, airedSeason: ep.airedSeason, episodeName: ep.episodeName, firstAired: ep.firstAired, filename: ep.filename, seriesId: ep.seriesId))
            }
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return episodes
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
                    episodes.append(Episode(id: ep.id, overview: ep.overview, airedEpisodeNumber: ep.airedEpisodeNumber, airedSeason: ep.airedSeason, episodeName: ep.episodeName, firstAired: ep.firstAired, filename: ep.filename, seriesId: ep.seriesId))
                }
            }
            catch {
                print("error executing fetch request: \(error)")
            }
        }
        return episodes
    }
    
    /// For debugging purposes, delete all children of a specific entity.
    static func dropTable() {
        // Wait, this isn't SQL.
        // TODO: Implement this
        
    }
}
