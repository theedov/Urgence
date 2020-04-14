//
//  AddDeviceVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class AddDeviceVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var deviceNameTxt: UTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //remove add device button from navigation bar
        navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func onNextPressed(_ sender: Any) {
        guard let deviceName = deviceNameTxt.text, deviceName.isNotEmpty else {
            AlertService.alert(state: .error, title: "Cannot add a device", body: "Device name cannot be empty", actionName: "I understand", vc: self, completion: nil)
            return
        }
        
        let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: VCIDs.QRDeviceScannerVC) as! QRDeviceScannerVC
        controller.deviceName = deviceNameTxt.text
        controller.presentingVC = self
//        self.navigationController?.pushViewController(controller, animated: true)
        self.navigationController?.present(controller, animated: true, completion: nil)
        
        
    }
    
}
