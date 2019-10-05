//
//  UTextField.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 5/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit

@IBDesignable
class UTextField: UITextField {

    //MARK: - Variables
    @IBInspectable var cornerRadius: CGFloat = 22 {
        didSet {
            setCornerRadius(value: cornerRadius)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        didSet {
            setBorderWidth(value: borderWidth)
        }
    }
    
    @IBInspectable var borderColor: UIColor = #colorLiteral(red: 0.2156862745, green: 0.2431372549, blue: 0.2862745098, alpha: 1) {
        didSet {
            setBorderColor(value: borderColor)
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
    
    func setBorderWidth(value: CGFloat) {
        self.layer.borderWidth = value
    }
    
    func setBorderColor(value: UIColor) {
        self.layer.borderColor = value.cgColor
    }
    
    func setup() {
        setCornerRadius(value: cornerRadius)
        setBorderWidth(value: borderWidth)
        setBorderColor(value: borderColor)
        
        self.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2431372549, blue: 0.2862745098, alpha: 0)
    }
}
