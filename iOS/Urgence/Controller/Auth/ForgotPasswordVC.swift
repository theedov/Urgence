//
//  ForgotPasswordVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {
    //Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTxt: UTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func backClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func passwordResetClicked(_ sender: Any) {
        guard let email = emailTxt.text, email.isNotEmpty else {
            debugPrint("Email is empty or not valid")
            return
        }
        
        activityIndicator.startAnimating()
        //send reset password email
        Auth.auth().sendPasswordReset(withEmail: email.noSpaces) { (error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.activityIndicator.stopAnimating()
                return
            }
            
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
    }

}
