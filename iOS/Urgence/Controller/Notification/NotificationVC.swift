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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTxt.isHidden = false
        showNotification()
        
        if notification.active {
            functions.httpsCallable("onNotificationOpen").call(["notification_id":notification.id]) { (result, error) in
                return
            }
        }
        
        hideButtonsIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }

    func showNotification() {
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
