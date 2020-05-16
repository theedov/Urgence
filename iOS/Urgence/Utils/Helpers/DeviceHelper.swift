//
//  DeviceHelper.swift
//  Urgence
//
//  Created by Bogdan on 3/4/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import Foundation
import UIKit

class DeviceHelper {
    static func getDeviceIcon(device: Device) -> UIImage {
        switch device.name {
        case "Living Room":
            return UIImage(named: "living-room")!
        case "Bed Room":
            return UIImage(named: "living-room")!
        default:
            return UIImage(named: "living-room")!
        }
    }
}
