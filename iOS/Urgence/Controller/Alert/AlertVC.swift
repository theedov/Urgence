//
//  AlertVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 26/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit

class AlertVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var bodyLbl: UITextView!
    @IBOutlet weak var actionBtn: UButton!
    @IBOutlet var bgView: UIView!
    
    var alertTitle = String()
    var alertBody = String()
    var actionBtnTitle = String()
    var btnAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        
        //add gesture recognizer to dismiss alert on background tap
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTap)))
    }
    
    @objc func dismissOnTap() {
        dismiss(animated: false, completion: nil)
    }
    
    fileprivate func setupView() {
        titleLbl.text = alertTitle
        bodyLbl.text = alertBody
        actionBtn.setTitle(actionBtnTitle, for: .normal)
    }
    
    @IBAction func didTapActionBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        btnAction?()
    }
    
    @IBAction func didTapCancelBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
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
