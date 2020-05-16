//
//  NotificationCell.swift
//  Urgence
//
//  Created by Bogdan on 15/5/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import UIKit

class NotificationCell: UICollectionViewCell {
    
    //Outlets
    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var dateTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(notification: UNotification) {
        titleTxt.text = notification.title
        dateTxt.text = dateToString(date: notification.createdAt.dateValue())
        
        if notification.active {
            titleTxt.font = UIFont.boldSystemFont(ofSize: titleTxt.font.pointSize)
        } else {
            titleTxt.font = UIFont.systemFont(ofSize: titleTxt.font.pointSize)
        }
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        
        return formatter.string(from: date)
    }

}
