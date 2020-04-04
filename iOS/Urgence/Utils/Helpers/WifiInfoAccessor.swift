//
//  WifiInfoAccessor.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 12/12/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation

let WifiInfoAccessor = _WifiInfoAccessor()

final class _WifiInfoAccessor: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    fileprivate func getCurrentSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    func getSSID() -> String? {
        if #available(iOS 13.0, *) {
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedWhenInUse {
                return getCurrentSSID()
            } else {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
            }
        } 
        return getCurrentSSID()
    }
}
