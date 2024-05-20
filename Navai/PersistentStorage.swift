//
//  PersistentStorage.swift
//  Navai
//
//  Created by Parbhat Jayaswal on 30/04/24.
//

import Foundation

import Foundation
import CoreData

final class PersistentStorage {
    
    
    private init(){}
    static let shared = PersistentStorage()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Navai")
        
        // To Sync data on iCloud
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No Descriptions found")
        }
        
        description.setOption(true as NSObject, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        // -- end here iCloud Code
        
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
        
        // To Sync data on iCloud
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.processUpdate), name: .NSPersistentStoreRemoteChange, object: nil)
        // -- end here iCloud Code
        
        
        return container
    }()

    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]?
    {
        do {
            guard let result = try PersistentStorage.shared.context.fetch(managedObject.fetchRequest()) as? [T] else {return nil}
            
            return result

        } catch let error {
            debugPrint(error)
        }
        
        return nil
    }
    
    
    // To Sync data on iCloud
    @objc
    func processUpdate(notification: NSNotification) {
        operationQueue.addOperation {
            // get our context
            let context = self.persistentContainer.newBackgroundContext()
            context.performAndWait {
                // get list items out of store
//                let items: [ListItem]
//                do {
//                    try items = context.fetch(ListItem.getListItemFetchRequest())
//                } catch {
//                    let nserror = error as NSError
//                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//                }
                
                // reorder items
//                items.enumerated().forEach { index, item in
//                    if item.order != index {
//                        item.order = index
//                    }
//                }
                
                // save if we need to save
//                if context.hasChanges {
//                    do {
//                        try context.save()
//                    } catch {
//                        let nserror = error as NSError
//                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//                    }
//                }
            }
            
        }
    }
    
    lazy var operationQueue: OperationQueue = {
       var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    // -- end here iCloud Code
    
}
