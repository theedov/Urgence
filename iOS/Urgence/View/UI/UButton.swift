//
//  UButton.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 5/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit

@IBDesignable
class UButton: UIButton {
    //MARK: - Variables
    @IBInspectable var cornerRadius: CGFloat = 22 {
        didSet {
            setCornerRadius(value: cornerRadius)
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
    func setCornerRadius(value: CGFloat) {
        self.layer.cornerRadius = value
    }
    
    func setup() {
        setCornerRadius(value: cornerRadius)
        self.backgroundColor = #colorLiteral(red: 0.1411764706, green: 0.1607843137, blue: 0.1921568627, alpha: 1) 
    }
}
