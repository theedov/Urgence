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
    var versionId: String
    var name: String
    var userId: String
    var update: Bool
    
    init(data: [String: Any]) {
        self.id = data["deviceId"] as? String ?? ""
        self.versionId = data["versionId"] as? String ?? "1.0"
        self.name = data["name"] as? String ?? ""
        self.userId = data["userId"] as? String ?? ""
        self.update = data["update"] as? Bool ?? false
    }
}
