//
//  QRDeviceScannerVC.swift
//  Urgence
//
//  Created by Bogdan on 1/4/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import UIKit
import AVFoundation

class QRDeviceScannerVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var cameraPreviewView: UIView!
    
    //Variables
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var deviceName: String!
    var presentingVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadScanner()  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension QRDeviceScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func loadScanner(){
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraPreviewView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        cameraPreviewView.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        createFirestoreDevice(deviceId: code)
    }
    
    func createFirestoreDevice(deviceId: String) {
        let uid = authUser!.uid
        let deviceRef = devicesDb.whereField("deviceId", isEqualTo: deviceId).whereField("userId", isEqualTo: uid)
        
        deviceRef.getDocuments { (snap, error) in
            if let error = error {
                debugPrint("ERROR: \(error.localizedDescription)")
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            if snap!.documents.isEmpty {
                let data = ["name": self.deviceName, "deviceId" : deviceId, "userId" : uid, "versionId" : "1.0"]
                devicesDb.addDocument(data: data as [String : Any]) { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        //Successfully added a device. Redirect back to MonitoringVC
                        self.dismiss(animated: true, completion: nil)
                        self.presentingVC.navigationController?.popToRootViewController(animated: false)
                    }
                }
            } else {
                self.dismiss(animated: true) {
                    self.captureSession = nil
                    AlertService.alert(state: .error, title: "Cannot add a device", body: "This device is already added.", actionName: "I understand", vc: self.presentingVC, completion: nil)
                }
            }
        }
    }
    
    func failed() {
        captureSession = nil
        dismiss(animated: true) {
            AlertService.alert(state: .error, title: "Scanning not supported", body: "Your device does not support scanning a code from an item. Please use a device with a camera.", actionName: "I understand", vc: self, completion: nil)
        }
    }
    
}
