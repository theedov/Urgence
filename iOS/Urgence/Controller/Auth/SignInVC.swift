//
//  SignInVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 5/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class SignInVC: UIViewController {
    //Outlets
    @IBOutlet weak var emailTxt: UTextField!
    @IBOutlet weak var passwordTxt: UTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func enterHouseClicked(_ sender: Any) {
        //check if singin details are empty
        guard let email = emailTxt.text, email.isNotEmpty,
            let password = passwordTxt.text, password.isNotEmpty else {
                debugPrint("Email or password cannot be empty")
                return
        }
        
        activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            //check if there is an error
            if let error = error {
                self?.activityIndicator.stopAnimating()
                debugPrint(error.localizedDescription)
                return
            }
            
            //check if signed in and if user has email verified
            if result != nil && !(result?.user.isEmailVerified)! {
                self?.activityIndicator.stopAnimating()
                // User is available, but their email is not verified.
                // Let the user know by an alert, preferably with an option to re-send the verification mail.
                debugPrint("User is available, but their email is not verified.")
                return
            }
            
            self?.activityIndicator.stopAnimating()
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}

