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
        passwordTxt.addTarget(self, action: #selector(onPasswordFieldChange(_:)), for: .editingChanged)
        confirmPasswordTxt.addTarget(self, action: #selector(onPasswordFieldChange(_:)), for: .editingChanged)
    }
    
    @objc func onPasswordFieldChange(_ textField: UITextField){
        
        guard let password = passwordTxt.text else { return }
        
        if textField == confirmPasswordTxt {
            passwordCheckImg.isHidden = false
            confirmPasswordCheckImg.isHidden = false
        } else {
            if password.isEmpty {
                passwordCheckImg.isHidden = true
                confirmPasswordCheckImg.isHidden = true
                confirmPasswordTxt.text = ""
            }
        }
        
        //when the passwords match, shows green check mark, else red cross
        if passwordTxt.text == confirmPasswordTxt.text {
            passwordCheckImg.image = UIImage(named: AppImages.Correct)
            confirmPasswordCheckImg.image = UIImage(named: AppImages.Correct)
        } else {
            passwordCheckImg.image = UIImage(named: AppImages.Incorrect)
            confirmPasswordCheckImg.image = UIImage(named: AppImages.Incorrect)
        }
        
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
    
    func validateFileds(){
        //check if fields are empty
        guard let currentPassword = currentPasswordTxt.text, currentPassword.isNotEmpty, let password = passwordTxt.text, password.isNotEmpty, let confirmPassword = confirmPasswordTxt.text, confirmPassword.isNotEmpty else {
            AlertService.alert(state: .error, title: "Cannot change password", body: "In order to change passwords, all fields are required", actionName: "I understand", vc: self, completion: nil)
            return
        }
        //check if password & confirmPassword match
        guard let confirmPass = confirmPasswordTxt.text, confirmPass == password else {
            AlertService.alert(state: .error, title: "Cannot change password", body: "Passwords do not match", actionName: "I understand", vc: self, completion: nil)
            return
        }
    }
    
}
