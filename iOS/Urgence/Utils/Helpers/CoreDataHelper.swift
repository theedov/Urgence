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
}
