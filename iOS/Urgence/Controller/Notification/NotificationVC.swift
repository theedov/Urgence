//
//  NotificationVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class NotificationVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var imageView: UImageView!
    @IBOutlet weak var headerTxt: UILabel!
    @IBOutlet weak var notificationView: UView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var feedbackTxt: UILabel!
    
    //Variables
    var notification: UNotification!
    var listener: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTxt.isHidden = false
        showNotificationImage()
        hideButtonsIfNeeded()
        //Mark notification 
        if !notification.viewed {
            functions.httpsCallable("onNotificationOpen").call(["notification_id":notification.id]) { (result, error) in
                return
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
        setNotificationListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
    }
    
    func setNotificationListener() {
        listener = notificationsDb.whereField("id", isEqualTo: notification.id).whereField("userId", isEqualTo: self.authUser!.uid).limit(to: 1).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                self.notification = UNotification.init(data: data)
                
                switch change.type {
                case .added: break
                case .modified:
                    self.hideButtonsIfNeeded()
                case .removed: break
                }
            })
        })
    }

    func showNotificationImage() {
        //present a notification image
        if let imageUrl = URL(string:notification!.imageUrl){
            do{
                let imageData = try Data(contentsOf: imageUrl)
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)
                    self.imageView.image = image
                }
            } catch {
                print("error")
            }
        }
    }
    
    func hideButtonsIfNeeded() {
        if notification.accepted || notification.declined {
            self.buttonStack.isHidden = true
            self.feedbackTxt.isHidden = false
        } else {
            self.buttonStack.isHidden = false
            self.feedbackTxt.isHidden = true
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onAcceptPressed(_ sender: Any) {
        if !notification.accepted {
            activityIndicator.startAnimating()
            functions.httpsCallable("onAcceptPrediction").call(["path":notification.imagePath, "notification_id":notification.id]) { (result, error) in
                if let error = error {
                    self.activityIndicator.stopAnimating()
                    debugPrint(error)
                    return
                }
                
                if let result = result, result.data as! Bool == true {
                    self.activityIndicator.stopAnimating()
                    self.notification.accepted = true
                    self.hideButtonsIfNeeded()
                }
            }
        }
    }
    
    @IBAction func onDeclinePressed(_ sender: Any) {
        if !notification.declined {
            activityIndicator.startAnimating()
            functions.httpsCallable("onDeclinePrediction").call(["notification_id":notification.id]) { (result, error) in
                if let error = error {
                    self.activityIndicator.stopAnimating()
                    debugPrint(error)
                    return
                }
                
                if let result = result, result.data as! Bool == true {
                    self.activityIndicator.stopAnimating()
                    self.notification.declined = true
                    self.hideButtonsIfNeeded()
                }
            }
        }
    }
}
