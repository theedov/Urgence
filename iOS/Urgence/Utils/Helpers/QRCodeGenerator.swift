//
//  QRCodeGenerator.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 12/12/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit

class QRCodeGenerator {
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
