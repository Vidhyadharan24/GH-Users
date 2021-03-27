//
//  PersistenceManager.swift
//  SwiftUI-Example
//
//  Created by Vidhyadharan on 05/03/21.
//

import CoreData

enum PersistanceError: Error {
    case readError(Error)
    case saveError(Error)
    case deleteError(Error)
}

struct PersistenceManager {
    static let shared = PersistenceManager()

    let container: NSPersistentContainer
    
    let viewContext: NSManagedObjectContext
    
    var backgroundContext: NSManagedObjectContext
    
    private init() {
        self.init(inMemory: false)
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GH_Users")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
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

        let stores = container.persistentStoreCoordinator.persistentStores
        for store in stores {
            print("\(store.configurationName) store url: \(String(describing: store.url))")
        }
        
        viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    func saveContext() {
        saveBackgroundContext()
        saveViewContext()
    }
    
    func saveViewContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveBackgroundContext() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
