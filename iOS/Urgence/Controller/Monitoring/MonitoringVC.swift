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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSignedIn()
        //reset notification badge number
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("MONITORING WINDOWS COUNT: \(UIApplication.shared.windows.count)")

    }
    
    fileprivate func isSignedIn() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil || user?.isEmailVerified == false {
                //user not logged in or not verified
                //present SignInVC
                self?.presentSignInVC()
            }
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
