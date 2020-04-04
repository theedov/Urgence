//
//  AddDeviceVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

protocol AddDeviceDelegate {
    func sendDeviceData(cameraId: String)
}

class AddDeviceVC: UIViewController {
    
    @IBOutlet weak var deviceIdTxt: UTextField!
    @IBOutlet weak var roomPicker: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pickerData: [String] = [String]()
    var isLivingRoom: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //remove add device button from navigation bar
        navigationItem.rightBarButtonItem = nil
        setupPickerView()
        
        
        
    }
    
    func setupPickerView() {
        roomPicker.delegate = self
        roomPicker.dataSource = self
        pickerData = ["Living Room", "Bedroom"]
    }
    
    
    @IBAction func onQRPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: StoryboardIDs.MainStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: VCIDs.QRDeviceScannerVC) as! QRDeviceScannerVC
        controller.delegate = self
        present(controller, animated: false, completion: nil)
    }
    
    @IBAction func onAddDevicePressed(_ sender: Any) {
        guard let deviceId = deviceIdTxt.text, deviceId.isNotEmpty else {
            AlertService.alert(state: .error, title: "Cannot add a device", body: "All fields are required", actionName: "I understand", vc: self, completion: nil)
            return
        }
        
        activityIndicator.startAnimating()
        createFirestoreDevice()
    }
    
    func createFirestoreDevice() {
        let deviceId = deviceIdTxt.text!
        let uid = authUser!.uid
        let deviceRef = Firestore.firestore().collection("devices").whereField("deviceId", isEqualTo: deviceId)
        
        deviceRef.getDocuments { [weak self] (snap, error) in
            if let error = error {
                self?.activityIndicator.stopAnimating()
                debugPrint("ERROR: \(error.localizedDescription)")
                return
            }

            if snap!.documents.isEmpty {
                let data = ["room": self?.pickerData[(self?.roomPicker.selectedRow(inComponent: 0))!], "deviceId" : deviceId, "userId" : uid]
                Firestore.firestore().collection("devices").addDocument(data: data as [String : Any]) { [weak self] (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    }else {
                        self?.activityIndicator.stopAnimating()
                        //Successfully added a device. Redirect back to MonitoringVC
                        self?.navigationController?.popViewController(animated: false)
                    }
                }
            } else {
                self?.activityIndicator.stopAnimating()
                AlertService.alert(state: .error, title: "Cannot add a device", body: "This device id is already in use", actionName: "I understand", vc: self!, completion: nil)
                return
            }
            
            
        }
    }
    
    func checkDeviceExistance(withDeviceId id: String) {
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension AddDeviceVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: pickerData[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "UText")!])
        
    }
}

extension AddDeviceVC: AddDeviceDelegate {
    func sendDeviceData(cameraId: String) {
        deviceIdTxt.text = cameraId
    }
}
