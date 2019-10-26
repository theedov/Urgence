//
//  UUIView.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 26/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class UView: UIView {
    //MARK: - Variables
    @IBInspectable var cornerRadius: CGFloat = 22 {
        didSet {
            setCornerRadius(radius: cornerRadius)
        }
    }
    
    @IBInspectable var radiusToAllCorners: Bool = false {
        didSet {
            setCornerRadius(radius: cornerRadius, allCornerRadius: radiusToAllCorners)
        }
    }
    
    //MARK: - Overrides
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    //MARK: - Modifications
    func setCornerRadius(radius: CGFloat, allCornerRadius: Bool = false) {
        //self.layer.cornerRadius = value
        if allCornerRadius == true {
            self.layer.cornerRadius = radius
        } else {
            self.roundCorners(corners: [.topLeft, .topRight], radius: radius)
        }
    }
    
    func setup() {
        //setCornerRadius(radius: cornerRadius, allCornerRadius: radiusToAllCorners)
        self.roundCorners(corners: [.topLeft, .topRight], radius: 22)
    }
}
