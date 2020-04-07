//
//  ChangePasswordVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var passwordTxt: UTextField!
    @IBOutlet weak var currentPasswordTxt: UTextField!
    @IBOutlet weak var confirmPasswordTxt: UTextField!
    @IBOutlet weak var passwordCheckImg: UIImageView!
    @IBOutlet weak var confirmPasswordCheckImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    

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
        beginPasswordChange()
    }
    
    func beginPasswordChange() {
        self.activityIndicator.startAnimating()
        validateFileds()
        
        let credential = EmailAuthProvider.credential(withEmail: authUser!.email!, password: currentPasswordTxt.text!)
        authUser!.reauthenticate(with: credential) { (result, error) in
            if let _ = error {
                self.activityIndicator.stopAnimating()
                AlertService.alert(state: .error, title: "Cannot change password", body: "There was an error reauthenticating user. Wrong current password.", actionName: "I understand", vc: self, completion: nil)
                return
            }
            //start changing user password
            self.changePassword()
        }
    }
    
    func changePassword(){
        self.authUser?.updatePassword(to: passwordTxt.text!, completion: { (error) in
            self.activityIndicator.stopAnimating()
            if let _ = error {
                AlertService.alert(state: .error, title: "Cannot change password", body: "There was an error changing your password. Please try again later or contact us directly: info@urgence.com.au", actionName: "I understand", vc: self, completion: nil)
                return
            }
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    func validateFileds(){
        //check if fields are empty
        guard let currentPassword = currentPasswordTxt.text, currentPassword.isNotEmpty, let password = passwordTxt.text, password.isNotEmpty, let confirmPassword = confirmPasswordTxt.text, confirmPassword.isNotEmpty else {
            self.activityIndicator.stopAnimating()
            AlertService.alert(state: .error, title: "Cannot change password", body: "In order to change passwords, all fields are required", actionName: "I understand", vc: self, completion: nil)
            return
        }
        //check if password & confirmPassword match
        guard let confirmPass = confirmPasswordTxt.text, confirmPass == password else {
            self.activityIndicator.stopAnimating()
            AlertService.alert(state: .error, title: "Cannot change password", body: "Passwords do not match", actionName: "I understand", vc: self, completion: nil)
            return
        }
    }
    
    
    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
