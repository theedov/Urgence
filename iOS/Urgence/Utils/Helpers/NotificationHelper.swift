//
//  NotificationHelper.swift
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
    
    static func deleteEntity(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try CoreDataHelper.getContext().fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                CoreDataHelper.getContext().delete(objectData)
            }
        } catch let error {
            print("Detele all data in error :", error)
        }
    }
}
