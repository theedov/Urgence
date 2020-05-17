//
//  NotificationListVC.swift
//  Urgence
//
//  Created by Bogdan on 14/5/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import UIKit
import Firebase

class NotificationListVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noNotificationsTxt: UILabel!
    
    
    //Variables
    var notifications = [UNotification]()
    var selectedNotification: UNotification!
    var listener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNotificationsListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        listener.remove()
        notifications.removeAll()
        collectionView.reloadData()
    }
    
    func showNoNotificationTextIfNeeded() {
        if(notifications.count == 0) {
            noNotificationsTxt.isHidden = false
        } else {
            noNotificationsTxt.isHidden = true
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: CellIDs.NotificationCell, bundle: nil), forCellWithReuseIdentifier: CellIDs.NotificationCell)

    }
    
    func setNotificationsListener() {
        listener = notificationsDb.whereField("userId", isEqualTo: self.authUser!.uid).order(by: "createdAt", descending: true).limit(to: 20).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let notification = UNotification.init(data: data)
                                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, notification: notification)
                case .modified:
                    self.onDocumentModified(change: change, notification: notification)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
            
            self.showNoNotificationTextIfNeeded()
        })
    }
    
    func onDocumentAdded(change: DocumentChange, notification: UNotification) {
        let newIndex = Int(change.newIndex)
        notifications.insert(notification, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    
    func onDocumentModified(change: DocumentChange, notification: UNotification) {
        if change.newIndex == change.oldIndex {
            //item changed but remained in the same position
            let index = Int(change.newIndex)
            notifications[index] = notification
            
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? NotificationCell {
                cell.configureCell(notification: notification)
            }
            
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
            
            
        } else {
            //item changed and changed position
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            notifications.remove(at: oldIndex)
            notifications.insert(notification, at: newIndex)
            
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        notifications.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
        
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIDs.ToNotificationVC {
            if let destination = segue.destination as? NotificationVC {
                destination.notification = selectedNotification
            }
        }
    }

}

// MARK: - TableView config
extension NotificationListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        notifications.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIDs.NotificationCell, for: indexPath) as? NotificationCell {
            cell.configureCell(notification: notifications[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedNotification = notifications[indexPath.row]
        performSegue(withIdentifier: SegueIDs.ToNotificationVC, sender: self)
    }
    
}
