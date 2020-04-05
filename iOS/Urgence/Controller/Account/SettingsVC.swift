//
//  SettingsVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignOutPressed(_ sender: Any) {
        do {
            //get fcm token
            let token = Messaging.messaging().fcmToken ?? "nil"
            let uid = self.authUser!.uid
            
            //Remove user token from notification group
            FcmTokenHandler.getUserGroupKey(uid: uid) { (key) in
                if key != nil {
                    FcmTokenHandler.removeTokenFromGroup(uid: uid, key: key!, tokens: [token])
                }
            }
            
            //remove fcmtoken from database
            let tokensRef = Firestore.firestore().collection("users").document(uid).collection("tokens")
            tokensRef.whereField("token", isEqualTo: token).getDocuments { (snap, error) in
                if let error = error {
                    return
                }
                
                snap!.documents.first?.reference.delete()
            }
            
            //sign out
            try Auth.auth().signOut()
            //redirect to MonitoringVC
            self.tabBarController?.selectedIndex = 0
        } catch let error as NSError  {
            AlertService.alert(state: .error, title: "Cannot register", body: error.localizedDescription, actionName: "I understand", vc: self, completion: nil)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
