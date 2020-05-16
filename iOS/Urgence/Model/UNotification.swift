//
//  UNotification.swift
//  Urgence
//
//  Created by Bogdan on 14/5/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import Foundation
import Firebase

struct UNotification {
    var id: String
    var userId: String
    var deviceId: String
    var title: String
    var imageUrl: String
    var imagePath: String
    var active:Bool
    var accepted: Bool
    var declined: Bool
    var createdAt: Timestamp
    
    init(data: [String:Any]) {
        id = data["id"] as? String ?? ""
        userId = data["userId"] as? String ?? ""
        deviceId = data["deviceId"] as? String ?? ""
        title = data["title"] as? String ?? ""
        imageUrl = data["imageUrl"] as? String ?? ""
        imagePath = data["imagePath"] as? String ?? ""
        active = data["active"] as? Bool ?? false
        accepted = data["accepted"] as? Bool ?? false
        declined = data["declined"] as? Bool ?? false
        createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
    }
}
