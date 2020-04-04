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
    
    @IBInspectable var borderColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {
            setBorderColor(value: borderColor)
        }
    }
    
    // MARK: - init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
//        setup()
        setCornerRadius(value: cornerRadius)
        setBorderWidth(value: borderWidth)
        setBorderColor(value: borderColor)
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8080000281, green: 0.8080000281, blue: 0.8080000281, alpha: 1)])//placeholder color
        self.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2431372549, blue: 0.2862745098, alpha: 0)
        self.borderStyle = .none
    }
    
    //MARK: - Modifications
    
    let padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 30);
    //text inset
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    //placeholder inset
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    //editing inset
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
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
        
        self.textColor = #colorLiteral(red: 0.8080000281, green: 0.8080000281, blue: 0.8080000281, alpha: 1)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8080000281, green: 0.8080000281, blue: 0.8080000281, alpha: 1)])//placeholder color
        self.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2431372549, blue: 0.2862745098, alpha: 0)
        self.borderStyle = .none
    }

}
