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

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCollectionView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSignedIn()
        //reset notification badge number
        

    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: Identifiers.DeviceCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.DeviceCell)
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

extension MonitoringVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.DeviceCell, for: indexPath) as? DeviceCell {
            cell.configureCell()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width
        let cellWidth = (width - 70) / 2
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    
}
