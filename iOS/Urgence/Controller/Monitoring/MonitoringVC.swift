//
//  MonitoringVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import Firebase

class MonitoringVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDevicesView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Variables
    var listener: ListenerRegistration!
    var devices = [Device]()
    var selectedDevice: Device!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupCollectionView()
        
        
//        devices.append(Device(id: "1", room: "test", userId: "dddd"))
//        devices.append(Device(id: "2", room: "test2", userId: "dddd2"))
//        devices.append(Device(id: "3", room: "test3", userId: "dddd3"))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isSignedIn()
        //will show a tutorial if there is no devices in devices array
        self.showAddDeviceTutorial()
        //listen to devices changes in firestore
        setDevicesListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener.remove()
        devices.removeAll()
        collectionView.reloadData()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: CellIDs.DeviceCell, bundle: nil), forCellWithReuseIdentifier: CellIDs.DeviceCell)
    }
    
    func isSignedIn() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil || user?.isEmailVerified == false {
                //user not logged in or not verified
                //present SignInVC
                self?.presentSignInVC()
            }
        }
    }
    
    func showAddDeviceTutorial() {
        //check if there is at least one device registered
        if devices.count > 0 {
            noDevicesView.isHidden = true
            return
        }
        
        //show add device tutorial
        noDevicesView.isHidden = false
    }
    
    func setDevicesListener() {
        listener = devicesDb.whereField("userId", isEqualTo: self.authUser?.uid).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let device = Device.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, device: device)
                case .modified:
                    self.onDocumentModified(change: change, device: device)
                case .removed:
                    self.onDocumentRemoved(change: change)
                }
            })
            
            //will show a tutorial if there is no devices in devices array
            self.showAddDeviceTutorial()
        })
    }
    
    func presentSignInVC(){
        let storyboard = UIStoryboard(name: StoryboardIDs.AuthStoryboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: VCIDs.SignInVC)
        present(controller, animated: false, completion: nil) 
    }
    
}

extension MonitoringVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func onDocumentAdded(change: DocumentChange, device: Device) {
        let newIndex = Int(change.newIndex)
        devices.insert(device, at: newIndex)
        collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
    }
    
    func onDocumentModified(change: DocumentChange, device: Device) {
        if change.newIndex == change.oldIndex {
            //item changed but remained in the same position
            let index = Int(change.newIndex)
            devices[index] = device
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            //item changed and changed position
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            devices.remove(at: oldIndex)
            devices.insert(device, at: newIndex)
            
            collectionView.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
        
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        devices.remove(at: oldIndex)
        collectionView.deleteItems(at: [IndexPath(item: oldIndex, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIDs.DeviceCell, for: indexPath) as? DeviceCell {
            cell.configureCell(device: devices[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numOfColumns: CGFloat = 2
        
        let spaceBetweenCells: CGFloat = 10
        let padding: CGFloat = 40
        let cellDimension = ((collectionView.bounds.width - padding) - (numOfColumns) * spaceBetweenCells) / numOfColumns
                
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedDevice = self.devices[indexPath.item]
        performSegue(withIdentifier: SegueIDs.ToDeviceVC, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 30,left: 20,bottom: 0,right: 20);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIDs.ToDeviceVC {
            if let destination = segue.destination as? DeviceVC {
                destination.device = selectedDevice
            }
        }
    }
    
}
