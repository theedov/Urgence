//
//  UImageView.swift
//  Urgence
//
//  Created by Bogdan on 2/4/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class UImageView: UIImageView {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
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

