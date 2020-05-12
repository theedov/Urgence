//
//  Device.swift
//  Urgence
//
//  Created by Bogdan on 3/4/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import Foundation

struct Device {
    var id: String
    var room: String
    var userId: String
    var update: Bool
    
    init(id: String, room: String, userId: String, update: Bool) {
        self.id = id
        self.room = room
        self.userId = userId
        self.update = update
    }
    
    init(data: [String: Any]) {
        self.id = data["deviceId"] as? String ?? ""
        self.room = data["room"] as? String ?? ""
        self.userId = data["userId"] as? String ?? ""
        self.update = data["update"] as? Bool ?? false
    }
}
