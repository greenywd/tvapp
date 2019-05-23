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
        print("PersistentContainer")
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
    
    static func entityExists(id: Int32) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteShows")
        fetchRequest.predicate = NSPredicate(format: "id = %@", NSNumber(value: id))
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try self.context.count(for: fetchRequest)
            print("COUNT: ", entitiesCount)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return entitiesCount > 0
    }
    
    /// For debugging purposes, delete all children of a specific entity.
    static func dropTable() {
        // Wait, this isn't SQL.
        // TODO: Implement this
        
    }
}
