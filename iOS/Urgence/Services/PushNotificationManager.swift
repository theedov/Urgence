//
//  PushNotificationManager.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject {
    let gcmMessageIDKey = "gcm.message_id"
    
    func registerForPushNotifications() {
        // [START set_messaging_delegate]
        Messaging.messaging().delegate = self
        // [END set_messaging_delegate]
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        // [END register_for_notifications]
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension PushNotificationManager : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("IN FOREGROUND \(userInfo)")
        print("IN FOREGROUND")
        
        // Change this to your preferred presentation option
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        if UIApplication.shared.applicationState == .inactive {
            //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
            presentNotificationVC()
        } else if UIApplication.shared.applicationState == .active {
            //app is currently active, can update badges count here
            presentNotificationVC()
            
        } else if UIApplication.shared.applicationState == .background {
            //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
            presentNotificationVC()
        }
        
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("TAPPED \(userInfo)")
        print("TAPPED")
        
        completionHandler()
    }
    
    fileprivate func presentNotificationVC() {
        let window = UIApplication.shared.windows.first
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UITabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        vc.selectedIndex = 1
//        sceneDeleage?.window?.makeKeyAndVisible()
//        sceneDeleage?.window?.rootViewController = vc
        window?.makeKeyAndVisible()
        window?.rootViewController = vc
    }
}
// [END ios_10_message_handling]

extension PushNotificationManager : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        updateFirestorePushTokenIfNeeded(data: dataDict)
    }
    
    
    func updateFirestorePushTokenIfNeeded(data: [String: Any]) {
        if Auth.auth().currentUser != nil {
            let usersRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
            usersRef.setData(data, merge: true)
        }
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("FCM FOREGROUND data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
