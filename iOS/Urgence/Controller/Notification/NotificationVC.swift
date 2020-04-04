//
//  NotificationVC.swift
//  Urgence
//
//  Created by Bogdan Dovgopol on 7/10/19.
//  Copyright © 2019 Urgence. All rights reserved.
//

import UIKit
import CoreData

class NotificationVC: UIViewController {
    
    //Outlets
    @IBOutlet weak var imageView: UImageView!
    @IBOutlet weak var headerTxt: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTxt.isHidden = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
        let context = CoreDataHelper.getContext()
        
        context.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")
            request.returnsObjectsAsFaults = false
            
            do {
                print("AAAAAAAAA: \(try context.fetch(request).count)")
                if let result = try context.fetch(request).first as? NSManagedObject {
                    if let imageUrl = URL(string:result.value(forKey: "image") as! String){
                        let imageData = try Data(contentsOf: imageUrl)
                        DispatchQueue.main.async {
                            let image = UIImage(data: imageData)
                            self.imageView.image = image
                        }
                    }
                }
            } catch {
                print("Failed")
            }
            
        }
    }
    
    @IBAction func onAcceptPressed(_ sender: Any) {
    }
    
    @IBAction func onDeclinePressed(_ sender: Any) {
//        //save to core data model
        let context = CoreDataHelper.getContext()

        //remove all data from entity
//        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")
//        let request = NSBatchDeleteRequest(fetchRequest: fetch)
//        do{
//            try context.execute(request)
//
//        } catch {
//            print("Failed cleaning up the Notification entity")
//        }
        
        if CoreDataHelper.deleteEntity(entityName: "Notification"){
            self.tabBarController?.selectedIndex = 0
        }
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
