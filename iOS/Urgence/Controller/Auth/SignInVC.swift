//
//  SignInVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 5/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SignInVC: UIViewController, CLLocationManagerDelegate {
    //Outlets
    @IBOutlet weak var emailTxt: UTextField!
    @IBOutlet weak var passwordTxt: UTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("SSID: \(WifiInfoAccessor.getSSID())")
//        if #available(iOS 13.0, *) {
//            let status = CLLocationManager.authorizationStatus()
//            if status == .authorizedWhenInUse {
//                print("XXXXXXX")
//            } else {
//                locationManager.delegate = self
//                locationManager.requestWhenInUseAuthorization()
//            }
//        }
    }
    
    
    @IBAction func enterHouseClicked(_ sender: Any) {
        //check if singin details are empty
        guard let email = emailTxt.text, email.isNotEmpty,
            let password = passwordTxt.text, password.isNotEmpty else {
                AlertService.alert(state: .error, title: "Cannot sign in", body: "In order to sign in, all fields are required", actionName: "I understand", vc: self, completion: nil)
                return
        }
        
        activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email.noSpaces, password: password) { [weak self] result, error in
            //check if there is an error
            if let error = error {
                self?.activityIndicator.stopAnimating()
                AlertService.alert(state: .error, title: "Cannot register", body: error.localizedDescription, actionName: "I understand", vc: self!, completion: nil)
                return
            }
            
            //check if signed in and if user has email verified
            if result != nil && !(result?.user.isEmailVerified)! {
                self?.activityIndicator.stopAnimating()
                // User is available, but their email is not verified.
                // Let the user know by an alert, preferably with an option to re-send the verification mail.
                
                AlertService.alert(state: .error, title: "Cannot sing in", body: "User is available, but their email is not verified.", actionName: "Send verification email", vc: self!) { [weak self] in
                    
                    //Send verification email
                    self?.authUser?.sendEmailVerification(completion: { [weak self] (error) in
                        if let error = error {
                            AlertService.alert(state: .error, title: "Cannot send verification email", body: error.localizedDescription, actionName: "I understand", vc: self!, completion: nil)
                            return
                        }
                        AlertService.alert(state: .success, title: "Verification email sent", body: "Email verification has been successfuly sent. Please check you email.", actionName: "I understand", vc: self!, completion: nil)
                    })
                    
                }
                return
            }
            
            let token = Messaging.messaging().fcmToken ?? ""
            FcmTokenHandler.getUserGroupKey(uid: Auth.auth().currentUser!.uid) { (key) in
                if key != nil {
                    FcmTokenHandler.updateToken(token: token, uid: Auth.auth().currentUser!.uid, key: key!)
                }
            }
            
            self?.activityIndicator.stopAnimating()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}

