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
    
    func setup() {
        //update button view
    }
}
