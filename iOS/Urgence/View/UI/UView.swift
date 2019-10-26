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
    
    //MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    //MARK: - Modifications
    func setCornerRadius(radius: CGFloat) {
        //self.layer.cornerRadius = value
        self.roundCorners(corners: [.topLeft, .topRight], radius: radius)
    }
    
    func setup() {
        setCornerRadius(radius: cornerRadius)
    }
}
