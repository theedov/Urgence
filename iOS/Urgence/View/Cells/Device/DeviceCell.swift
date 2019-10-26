//
//  DeviceCell.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 26/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit

class DeviceCell: UICollectionViewCell {
    
    //MARK: - Variables
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UIImageView!
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - Config
    func configureCell() {
        
    }

}
