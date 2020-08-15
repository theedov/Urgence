//
//  FcmTokenHandler.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 27/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import Foundation
import Firebase

class FcmTokenHandler {
    
    /**
     Saves device fcm token to the users/{uid}/tokens collection.

     - parameter token: *fcmToken*
     - parameter uid: Unique user id

     # Notes: #
     1. Parameters must be **string** type
    */
    static func saveToken(token: String, uid: String) {
        Firestore.firestore().collection("users").document(uid).collection("tokens").addDocument(data: ["token" : token])
    }
    
    /**
     Access' a notification group key, which is saved in users/{uid} document in key field

     - parameter uid: Unique user id
     - parameter completion: Notification group key

     # Notes: #
     1. Parameters must be **string** type
    */
    static func getUserGroupKey(uid: String, completion: @escaping (String?) -> Void) {
        let keyRef = Firestore.firestore().collection("users").document(uid)
        keyRef.getDocument { (snap, error) in
            if let error = error {
                debugPrint("Error: \(error.localizedDescription)")
                return completion(nil)
            }
            
            let key = snap!.get("key") as? String
//            debugPrint("Key: \(key)")
            return completion(key)
        }
    }
    
    /**
        Updates old device fcm token in users/{uid}/tokens to new one

        - parameter token: Device FCM Token
        - parameter uid: Unique user id

        # Notes: #
        1. Parameters must be **string** type
    */
    static func updateToken(token: String, uid: String, key: String) {
        let tokenRef = Firestore.firestore().collection("users").document(uid).collection("tokens").whereField("token", isEqualTo: token)
        
        tokenRef.getDocuments { (snap, error) in
            if let error = error {
                debugPrint("ERROR: \(error.localizedDescription)")
                return
            }

            if snap!.documents.isEmpty {
                saveToken(token: token, uid: uid)
                addTokenToGroup(uid: uid, key: key, tokens: [token])
            }
        }
    }
    
    /**
        Registers a new notification group and returns notofication group key in closure

        - parameter uid: Unique user id
        - parameter tokens: Array of FCM Tokens
        - parameter completion: Notification group key
    */
    static func registerNotificationGroup(uid: String, tokens: [String], completion: @escaping (String?)-> Void) {
        let parameters = [
            "operation" : "create",
            "notification_key_name" : uid,
            "registration_ids" : tokens
            ] as [String : Any]
        let headers = [
            "Content-Type" : "application/json",
            "Authorization" : "key=\(NotificationAuthorization.Key)",
            "project_id" : "\(NotificationAuthorization.Project_ID)"
        ]
        RESTful.request(path: "https://fcm.googleapis.com/fcm/notification", method: "POST", parameters: parameters, headers: headers) { (data, response, error) in
            if let error = error {
                debugPrint("ERROR: \(error.localizedDescription)")
                return completion(nil)
            }
            guard let data = data else {
                print("Error: Did not receive data from API")
                return completion(nil)
            }
            
            do {
                let rootJSONObject = try JSONSerialization.jsonObject(with: data)
                
                guard let jsonArray = rootJSONObject as? [String:Any] else {return}
            
                if (jsonArray["error"] == nil) {
                    debugPrint("Key: \(jsonArray["notification_key"])")
                    return completion(jsonArray["notification_key"] as? String)
                }
                
            } catch {
                return completion(nil)
            }
        }
    }

    /**
        Adds a new device fcm token to a notification group

        - parameter uid: Unique user id
        - parameter key: Notification group **key**
        - parameter tokens: Array of FCM Tokens

        # Notes: #
        1. Parameters must be **string** type
    */
    static func addTokenToGroup(uid: String, key: String, tokens: [String]) {
        let parameters = [
            "operation" : "add",
            "notification_key_name" : uid,
            "notification_key" : key,
            "registration_ids" : tokens
            ] as [String : Any]
        let headers = [
            "Content-Type" : "application/json",
            "Authorization" : "key=\(NotificationAuthorization.Key)",
            "project_id" : "\(NotificationAuthorization.Project_ID)"
        ]
        RESTful.request(path: "https://fcm.googleapis.com/fcm/notification", method: "POST", parameters: parameters, headers: headers) { (data, response, error) in
            if let error = error {
                debugPrint("ERROR: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("Error: Did not receive data from API")
                return
            }
            
            do {
                let rootJSONObject = try JSONSerialization.jsonObject(with: data)
                
                guard let jsonArray = rootJSONObject as? [String:Any] else {return}
            
                if (jsonArray["error"] == nil) {
                    debugPrint(jsonArray["error"] as? String ?? "")
                    return
                }
                
            } catch {
                debugPrint("Error in json serialization")
                return
            }
        }
    }
    
    /**
        Removes a device fcm token from a notification group

        - parameter uid: Unique user id
        - parameter key: Notification group **key**
        - parameter tokens: Array of FCM Tokens
    */
    static func removeTokenFromGroup(uid: String, key: String, tokens: [String]) {
        let parameters = [
            "operation" : "remove",
            "notification_key_name" : uid,
            "notification_key" : key,
            "registration_ids" : tokens
            ] as [String : Any]
        let headers = [
            "Content-Type" : "application/json",
            "Authorization" : "key=\(NotificationAuthorization.Key)",
            "project_id" : "\(NotificationAuthorization.Project_ID)"
        ]
        RESTful.request(path: "https://fcm.googleapis.com/fcm/notification", method: "POST", parameters: parameters, headers: headers) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error)")
                return
            }
            guard let data = data else {
                print("Error: Did not receive data from API")
                return
            }
            
            do {
                let rootJSONObject = try JSONSerialization.jsonObject(with: data)
                
                guard let jsonArray = rootJSONObject as? [String:Any] else {return}
            
                if (jsonArray["error"] != nil) {
                    debugPrint(jsonArray["error"] as? String ?? "")
                    return
                }
                
            } catch {
                debugPrint("Error in json serialization")
                return
            }
        }
    }
}
