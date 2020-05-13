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
    
    //Outlets
    @IBOutlet weak var versionTxt: UILabel!
    @IBOutlet weak var automaticUpdatesSwitch: UISwitch!
    
    
    //Variables
    var listener: ListenerRegistration!
    var device: Device!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = device.room
        self.db = Firestore.firestore()
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(animated)
        UIView.setAnimationsEnabled(false)
        
        setDeviceListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIView.setAnimationsEnabled(true)
    }
    
    func updateUI(){
        automaticUpdatesSwitch.isOn = device.update
        versionTxt.text = device.versionId
    }
    
    func setDeviceListener() {
        listener = db.collection("devices").whereField("deviceId", isEqualTo: device.id).whereField("userId", isEqualTo: self.authUser!.uid).limit(to: 1).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                self.device = Device.init(data: data)
                
                switch change.type {
                case .modified:
                    self.changeUpdateState(isEnabled: self.device.update)
                    self.updateUI()
                    break
                case .added:
                    break
                case .removed:
                    break
                }
            })
        })
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
    
    @IBAction func onAutoUpdatesSwitchPressed(_ sender: UISwitch) {
        if sender.isOn == true {
            changeUpdateState(isEnabled: true)
        } else {
            changeUpdateState(isEnabled: false)
        }
    }
    
    func changeUpdateState(isEnabled: Bool){
        //search for all devices with provided device.id
        db.collection("devices").whereField("deviceId", isEqualTo: device.id).getDocuments { (snap, error) in
            //notify when error occurs
            if let _ = error {
                AlertService.alert(state: .error, title: "Enabling updates", body: "Updates cannot be enabled right now. Please try later or contact use directly.", actionName: nil, vc: self, completion: nil)
            }
            
            if let snap = snap {
                //loop through the all results
                for document in snap.documents {
                    let deviceRef = document.reference
                    //enable device updates in DB
                    deviceRef.updateData(["update": isEnabled]) { (error) in
                        //notify when error occurs
                        if let _ = error {
                            AlertService.alert(state: .error, title: "Enabling updates", body: "Updates cannot be enabled right now. Please try later or contact use directly.", actionName: nil, vc: self, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
