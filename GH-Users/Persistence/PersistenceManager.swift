//
//  PersistenceManager.swift
//  SwiftUI-Example
//
//  Created by Vidhyadharan on 27/03/21.
//

import CoreData

public enum PersistenceError: Error {
    case noData
    case readError(Error?)
    case saveError(Error?)
    case deleteError(Error?)
}

struct PersistenceManager {
    static let shared = PersistenceManager()

    let container: NSPersistentContainer
    
    // BONUS TASK: CoreData stack implementation must use ​two managed contexts​ - 1.​main context​ to
    // be used for reading data and feeding into UI 2. write (​background) context​ - that is used for writing data
    let viewContext: NSManagedObjectContext
    
    // BONUS TASK: All CoreData ​write​ queries must be ​queued​ while allowing one concurrent query at any time.
    // The backgroundContext is initialized from `container.newBackgroundContext()`, the queries to the bacground context are executed in serial by default. All the write tasks in the app are done in this context.
    private var backgroundContext: NSManagedObjectContext
    
    private let serialQueue = DispatchQueue(label: "cd.serial.queue")
    
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
    
    // MARK: BUGS - CD save shouldn't happend on the main thread: Saves the data to coredata using a thread from the systems thread pool except the main thread
    func saveInBackgroundContext(task: @escaping (NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        serialQueue.async {
            backgroundContext.perform {
                task(context)
            }
        }
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
