//
//  CoreDataHelper.swift
//  Urgence
//
//  Created by Bogdan on 1/4/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataHelper {
    static func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        return context
    }
    
    static func getPrivateQueContext() -> NSManagedObjectContext {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = self.getContext()
        
        return privateMOC
    }
    
    static func deleteEntity(entityName: String) -> Bool{
        //save to core data model
        let context = self.getContext()
        
        //remove all data from entity
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do{
            try context.execute(request)
            return true
        } catch {
            print("Failed cleaning up the Notification entity")
            return false
        }
    }
}
