//
//  AlertService.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 26/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit

enum AlertState {
    case error
    case warning
    case success
}

class AlertService {
    static func alert(state: AlertState, title: String, body: String, actionName: String, vc: UIViewController, completion: (() -> Void)?) {
        let storyboard = UIStoryboard(name: StoryboardIDs.AlertStoryboard, bundle: .main)
        let alertVC = storyboard.instantiateViewController(identifier: VCIDs.AlertVC) as! AlertVC
        
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.actionBtnTitle = actionName
        alertVC.btnAction = completion
        
        vc.present(alertVC, animated: true, completion: nil)
    }
    
}
