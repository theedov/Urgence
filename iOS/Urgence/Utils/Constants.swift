//
//  Constants.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Firebase

//shared variables
let db = Firestore.firestore()
let functions = Functions.functions()
let usersDb = db.collection("users")
let devicesDb = db.collection("devices")
let notificationsDb = db.collection("notifications")



enum StoryboardIDs {
    static let MainStoryboard = "Main"
    static let AuthStoryboard = "Auth"
    static let AlertStoryboard = "Alert"
}

enum VCIDs {
    static let AlertVC = "AlertVC"
    static let SignInVC = "SignInVC"
    static let QRDeviceScannerVC = "QRDeviceScannerVC"
    static let DeviceVC = "DeviceVC"
    static let NotificationVC = "NotificationVC"
}

enum CellIDs {
    static let DeviceCell = "DeviceCell"
    static let NotificationCell = "NotificationCell"
}

enum SegueIDs {
    static let ToDeviceVC = "toDeviceVC"
    static let ToNotificationVC = "toNotificationVC"
}

enum CoreDataEntities {
    static let Notification = "Notification"
}

enum AppImages {
    static let Correct = "correct"
    static let Incorrect = "incorrect"
}

