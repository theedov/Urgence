//
//  MonitoringDetailVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class DeviceVC: UIViewController {
    
    //Variablse
    var device: Device!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = device.room
        self.db = Firestore.firestore()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        UIView.setAnimationsEnabled(false)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    @IBAction func onDisconnectDevicePressed(_ sender: Any) {
        AlertService.alert(state: .warning, title: "Are you sure you want to disconnect this device?", body: "If you disconnect, you will no longer receive notifications from it.", actionName: "Disconnect", vc: self) {
            self.disconnectDevice()
        }
    }
    
    func disconnectDevice() {
        //find the device in db based on userId and deviceId
        db.collection("devices").whereField("userId", isEqualTo: device.userId).whereField("deviceId", isEqualTo: device.id).limit(to: 1)
            .getDocuments() { (snap, err) in
                if let err = err {
                    print("Error getting devices: \(err)")
                } else {
                    for deviceItem in snap!.documents {
                        deviceItem.reference.delete()
                    }
                    //go back to MonitoringVC
                    self.navigationController?.popViewController(animated: false)
                }
        }
    }
}
