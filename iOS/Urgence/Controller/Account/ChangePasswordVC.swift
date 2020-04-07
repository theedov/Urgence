//
//  ChangePasswordVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var passwordTxt: UTextField!
    @IBOutlet weak var currentPasswordTxt: UTextField!
    @IBOutlet weak var confirmPasswordTxt: UTextField!
    @IBOutlet weak var passwordCheckImg: UIImageView!
    @IBOutlet weak var confirmPasswordCheckImg: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        changePassword()
    }
    
    func changePassword() {
        self.authUser?.updatePassword(to: passwordTxt.text!, completion: { (error) in
            if let _ = error {
                AlertService.alert(state: .error, title: "Cannot change password", body: "There was an error changing your password. Please try again later or contact us directly: info@urgence.com.au", actionName: "I understand", vc: self, completion: nil)
            }
        })
    }
    
}
