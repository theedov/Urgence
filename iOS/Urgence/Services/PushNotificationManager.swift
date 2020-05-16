//
//  PushNotificationManager.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications

class PushNotificationManager: NSObject {
    let gcmMessageIDKey = "gcm.message_id"
    
    func registerForPushNotifications() {
//                debugPrint("Notofication registration started")
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
//                debugPrint("Notofication registration finished")
        
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
//                debugPrint("Notification received in foreground")

        //save notification to coredata
        self.openNotification(notification: notification)

        // Change this to your preferred presentation option
        completionHandler(.alert)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
//                debugPrint("Notification received in background")

        //save notification to coredata
        self.openNotification(notification: response.notification)

        completionHandler()
    }
    
    fileprivate func openNotification(notification: UNNotification) {
        
        //get notification data
        let notification = notification.request.content
        let userInfo = notification.userInfo
        
        if let deeplink = userInfo["dl"] as? String, let url = URL(string: deeplink), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func presentNotificationVC() {
        let window = UIApplication.shared.windows.first
        let storyboard : UIStoryboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let vc : UITabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as! UITabBarController
        vc.selectedIndex = 1
        
        window?.makeKeyAndVisible()
        window?.rootViewController = vc
    }
    
}
// [END ios_10_message_handling]

extension PushNotificationManager : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        //        debugPrint("New token received: \(fcmToken)")
        updateFirestorePushTokenIfNeeded(token: fcmToken)
    }
    
    
    func updateFirestorePushTokenIfNeeded(token: String) {
        if let uid = Auth.auth().currentUser?.uid {
            FcmTokenHandler.getUserGroupKey(uid: uid) { (key) in
                if key != nil {
                    FcmTokenHandler.updateToken(token: token, uid: uid, key: key!)
                }
            }
        }
    }
    
    
}
