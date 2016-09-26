//
//  LoggedInViewController.swift
//  Demo1.0
//
//  Created by User on 2016-09-24.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseStorage

class LoggedInViewController: UIViewController {

    // Add Active/Inactive status that changes on logout
    // Format phone number correctly
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    var uid: String = (FIRAuth.auth()?.currentUser?.uid)!
    
    var ref = FIRDatabase.database().reference()
    
    var user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if let user = FIRAuth.auth()?.currentUser {
            
            self.ref.child("Users").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.hasChild(self.uid) {
                    self.ref.child("Users").child(self.uid).observeEventType(.Value, withBlock: { snapshot in
                        
                        let dataPull = snapshot.value! as! [String:String]
                        
                        if snapshot.hasChild("Name") {
                            self.nameField.text = dataPull["Name"]!
                        }
                        
                        if snapshot.hasChild("Email") {
                            self.emailField.text = dataPull["Email"]!
                        }
                        
                        if snapshot.hasChild("Phone") {
                            self.phoneField.text = dataPull["Phone"]!
                        }
                        
                    })
                    
                } else {
                    
                        let name: String = user.displayName! as String
                        let email: String = user.email! as String
                        self.uid = user.uid as String
                    self.ref.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":""])
                }
                
            })
            
            
        } else {
            
            //no one is signed in
            
        }

        // Do any additional setup after loading the view.
    }

    @IBAction func didTapLogout(sender: AnyObject) {
        // signs user out of Firebase
        try! FIRAuth.auth()!.signOut()
        
        // signs user out of Facebook app
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        let accountViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("accountView")
        
        self.presentViewController(accountViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nameFieldChanged(sender: AnyObject) {
        
        let nameFieldText = self.nameField.text! as String
        
        self.ref.child("Users").child(self.uid).child("Name").setValue(nameFieldText)
        
    }

    @IBAction func emailFieldChanged(sender: AnyObject) {
        
        let emailFieldText = self.emailField.text! as String
        
        self.ref.child("Users").child(self.uid).child("Email").setValue(emailFieldText)
        
    }
    
    @IBAction func phoneFieldChange(sender: AnyObject) {
        
        let phoneFieldText = self.phoneField.text! as String
        
        self.ref.child("Users").child(self.uid).child("Phone").setValue(phoneFieldText)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
