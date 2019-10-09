//
//  MonitoringVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class MonitoringVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isSignedIn()
    }
    
    fileprivate func isSignedIn() {
        if let user = self.authUser {
            //user logged in
            debugPrint(user.email)
        } else {
            //user not logged in
            //present SignInVC
            presentSignInVC()
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            isSignedIn()
        } catch let error as NSError  {
            debugPrint(error.localizedDescription)
        }
    }
    
    fileprivate func presentSignInVC(){
        let storyboard = UIStoryboard(name: Storyboard.AuthStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.Auth)
        present(controller, animated: false, completion: nil) 
    }

}
