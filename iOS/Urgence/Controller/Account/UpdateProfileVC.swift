//
//  UpdateProfileVC.swift
//  Urgence
//
//  Created by Bogdan on 7/4/20.
//  Copyright © 2020 Urgence. All rights reserved.
//

import UIKit
import Firebase

class UpdateProfileVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var fullNameTxt: UTextField!
    @IBOutlet weak var emailTxt: UTextField!
    @IBOutlet weak var profilePicture: UImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    
    
    //Variables
    var profileImageChanged = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //enable tap gesture for profilePicture
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.loadPhotoLibrary(tapGestureRecognizer:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProfileDetails()
        loadProfilePicture()
    }
    
    @objc func loadPhotoLibrary(tapGestureRecognizer: UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func loadProfilePicture(){
        imageActivityIndicator.startAnimating()
        let filePath = "users/\(authUser!.uid)/profile/profile-picture"
        Storage.storage().reference().child(filePath).downloadURL { (url, error) in
            if let error = error {
                self.imageActivityIndicator.stopAnimating()
                debugPrint("Error getting downloadURL: \(error)")
                return
            }
            self.imageActivityIndicator.stopAnimating()
            
            if let url = url {
                //present profile picture
                self.profilePicture.load(url: url)
            } else {
                //present profile placeholder
                self.profilePicture.image = UIImage(named: "camera")
            }
        }
    }
    
    func loadProfileDetails() {
        usersDb.document(authUser!.uid).getDocument { (document, error) in
            if let error = error {
                debugPrint("Error getting profile details: \(error)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.fullNameTxt.text = data?["fullName"] as? String ?? ""
                self.emailTxt.text = data?["email"] as? String ?? ""
            } else {
                print("User document does not exist")
            }
        }
    }
    
    @IBAction func onSavePressed(_ sender: Any) {
        self.activityIndicator.startAnimating()
        updateProfile()
        navigationController?.popViewController(animated: true)
    }
    
    func updateProfile() {
        //check if all fields are filled in
        guard let fullName = fullNameTxt.text, fullName.isNotEmpty, let email = emailTxt.text, email.isNotEmpty else {
            self.activityIndicator.stopAnimating()
            AlertService.alert(state: .error, title: "Cannot update profile details", body: "In order to update profile details, all fields must be filled in", actionName: nil, vc: self, completion: nil)
            return
        }
        
        //check if provided email is valid
        guard email.isEmailNotValid else {
            self.activityIndicator.stopAnimating()
            AlertService.alert(state: .error, title: "Cannot update profile details", body: "Provided email is not valid, please provide valid email address.", actionName: nil, vc: self, completion: nil)
            return
        }
        
        //Update firestore & firebase storage
        updateDetails()
    }

    
    func updateDetails(){
        //update firestore details
        let fields = ["fullName":fullNameTxt.text!, "email":emailTxt.text!.noSpaces]
        
        usersDb.document(authUser!.uid).updateData(fields) { (error) in
            if let _ = error {
                self.activityIndicator.stopAnimating()
                AlertService.alert(state: .error, title: "Cannot update profile details", body: "Please try it later or contact us directly: info@urgence.com.au", actionName: nil, vc: self, completion: nil)
                return
            }
            self.updateProfilePicture()
        }
    }
    
    func updateProfilePicture(){
        //check if user has picked new profile picture
        activityIndicator.stopAnimating()
        if profileImageChanged == false {
            return
        }
        
        //delete current image
        deleteImage(path: "users/\(authUser!.uid)/profile/profile-picture")
        //upload new profile picture to the storage
        uploadImage(image: profilePicture.image!)
    }
    
    func uploadImage(image: UIImage){
        // Data in memory
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        //set upload path
        let filePath = "users/\(authUser!.uid)/profile/profile-picture" //path to save image in storage
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        
        // Create a reference to the file you want to upload
        Storage.storage().reference().child(filePath).putData(data, metadata: metaData) { (metadata, error) in
            if let _ = error {
                self.activityIndicator.stopAnimating()
                AlertService.alert(state: .error, title: "Cannot upload an image", body: "", actionName: "I understand", vc: self, completion: nil)
                return
            }
            
            self.activityIndicator.stopAnimating()
        }
        
    }
    
    func deleteImage(path: String){
        // Delete the file
        Storage.storage().reference().child(path).delete { error in
            self.activityIndicator.stopAnimating()
            if let error = error {
                debugPrint("Error deleting the file: \(error)")
                return
            }
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
}

extension UpdateProfileVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //get selected image
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        //load picked image into the profilePicture
        self.profilePicture.image = pickedImage
        self.profileImageChanged = true
        picker.dismiss(animated: true, completion: nil)
    }
}
