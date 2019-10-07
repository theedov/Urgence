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
    
    //text inset
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }
    
    //placeholder inset
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0)
    }
    
    //editing inset
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 20, dy: 0);
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
        
        self.textColor = #colorLiteral(red: 0.8080000281, green: 0.8080000281, blue: 0.8080000281, alpha: 1)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8080000281, green: 0.8080000281, blue: 0.8080000281, alpha: 1)])//placeholder color
        self.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.2431372549, blue: 0.2862745098, alpha: 0)
        self.borderStyle = .none
    }

}
