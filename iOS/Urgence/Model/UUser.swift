//
//  User.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 24/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import Foundation

struct UUser {
    var id: String
    var email: String
    var fullName: String
    
    init(id: String = "", email: String = "", fullName: String = "") {
        self.id = id
        self.email = email
        self.fullName = fullName
    }
    
    init(data: [String: Any]) {
        id = data["id"] as? String ?? ""
        email = data["email"] as? String ?? ""
        fullName = data["fullName"] as? String ?? ""
    }
    
    static func modelToData(user: UUser) -> [String: Any] {
        let data : [String: Any] = [
            "id": user.id,
            "email" : user.email,
            "fullName" : user.fullName
        ]
        
        return data
    }
}
