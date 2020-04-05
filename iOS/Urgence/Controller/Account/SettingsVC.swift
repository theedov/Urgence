//
//  SettingsVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

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
    
    @IBAction func onSupportPressed(_ sender: Any) {
        showEmailComposer()
    }
    
    func showEmailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            //show alert informing the user
            AlertService.alert(state: .error, title: "Cannot send emails", body: "This device cannot send email", actionName: "I understand", vc: self, completion: nil)
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["support@urgence.com.au"])
        composer.setSubject("InApp Support - Urgence")
        composer.setMessageBody("Please in detail describe your issue", isHTML: false)
        present(composer, animated: true)
    }
}

extension SettingsVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            //show error alert
            AlertService.alert(state: .error, title: "Error sending email", body: "There was an error: \(String(describing: error))", actionName: "I understand", vc: self, completion: nil)
            controller.dismiss(animated: true, completion: nil)
        }
        
        switch result {
        case .cancelled:
            AlertService.alert(state: .warning, title: "Email cancelled", body: "It seems you have cancelled your your email ticked", actionName: "I understand", vc: self, completion: nil)
        case .failed:
            AlertService.alert(state: .error, title: "Email failed", body: "It seems your email ticked has not been send. Please try it later or contact use directly via email support@urgence.com.au", actionName: "I understand", vc: self, completion: nil)
        case .saved:
            AlertService.alert(state: .warning, title: "Email saved", body: "Your email ticked has been saved.", actionName: "I understand", vc: self, completion: nil)
        case .sent:
            AlertService.alert(state: .success, title: "Email sent", body: "Your email ticked has been sent. We will be in touch shortly.", actionName: "I understand", vc: self, completion: nil)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
