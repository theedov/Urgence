//
//  Extensions.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var isEmailNotValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: self)
    }
    
    var isEmailValid: Bool {
        return !isEmailNotValid
    }
}

extension UIViewController {
    //get current user if available
    var authUser : User? {
        return Auth.auth().currentUser
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIImageView {
    
    func load(url: URL) {
        DispatchQueue.main.async {
            self.kf.setImage(
                with: url,
                options: [
                    .processor(DownsamplingImageProcessor(size: self.bounds.size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
            ])
        }
    }
}
