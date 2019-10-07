//
//  SignUpVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    //Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var fullNameTxt: UTextField!
    @IBOutlet weak var emailTxt: UTextField!
    @IBOutlet weak var passwordTxt: UTextField!
    @IBOutlet weak var confirmPasswordTxt: UTextField!
    
    @IBOutlet weak var fullNameCheck: UIImageView!
    @IBOutlet weak var emailCheckImg: UIImageView!
    @IBOutlet weak var passwordCheckImg: UIImageView!
    @IBOutlet weak var confirmPasswordCheckImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func newResidentClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty, let password = passwordTxt.text, password.isNotEmpty else {
            debugPrint("Email or password is empty")
            return
        }
        activityIndicator.startAnimating()
        //register user
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error {
                self?.activityIndicator.stopAnimating()
                debugPrint(error.localizedDescription)
                return
            }
            
            //send verification email to confirm the account
            self?.sendVerificationEmail(completion: { [weak self] (success, error) in
                if !success {
                    self?.activityIndicator.stopAnimating()
                    debugPrint("User is not available, or has been already verified")
                }
                
                self?.activityIndicator.stopAnimating()
            })
        }
    }
    
    private func sendVerificationEmail(completion: @escaping (Bool, Error?) -> Void) {
        //check if user has email verified
        if self.authUser != nil && !self.authUser!.isEmailVerified {
            self.authUser?.sendEmailVerification(completion: { [weak self] (error) in
                // Notify the user that the mail has sent or couldn't because of an error.
                if let error = error {
                    debugPrint(error)
                    return completion(false, error)
                }
                debugPrint("Email has been sent")
                return completion(true, nil)
            })
        } else {
            // Either the user is not available, or the user is already verified.
            debugPrint("User is not available, or has been already verified")
            return completion(false, "User is not available, or has been already verified" as? Error)
        }
    }
    
    @IBAction func memberAlready(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
