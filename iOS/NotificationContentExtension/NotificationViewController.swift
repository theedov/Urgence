//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by Bogdan Dovgopol on 27/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet var label: UILabel?
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
        
        let attachments = notification.request.content.attachments
        for attachment in attachments {
            guard let data = try? Data(contentsOf: attachment.url) else {return}
            image.image = UIImage(data: data)
        }
    }

}
