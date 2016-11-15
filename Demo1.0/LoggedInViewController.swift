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
import GoogleSignIn

class LoggedInViewController: UIViewController, UITextViewDelegate {

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
    var authProvider = String()
    var emailAuthEmail = String()
    var emailAuthName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        logoutButton.layer.cornerRadius = 15
        
        if let user = FIRAuth.auth()?.currentUser {
            
            self.ref.child("Users").child(self.uid).observe(.value, with: { snapshot in
                        
                if snapshot.hasChild("Name") {
                    
                    let dataPull = snapshot.value! as! [String:AnyObject]
                    
                    self.nameField.text = dataPull["Name"]! as? String
                    
                    if snapshot.hasChild("Email") {
                        self.emailField.text = dataPull["Email"]! as? String
                    } else if self.authProvider == "Email" {
                        let name: String = self.emailAuthName
                        let email: String = self.emailAuthEmail
                        self.uid = user.uid as String
                        
                        self.ref.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":"","Status":"Active"])
                    }
                    
                    if snapshot.hasChild("Phone") {
                        self.phoneField.text = dataPull["Phone"]! as? String
                    }
                    
                }
                
                /*else {
                    
                    if self.authProvider == "Facebook" || self.authProvider == "Google" {
                        
                        let name: String = user.displayName! as String
                        let email: String = user.email! as String
                        self.uid = user.uid as String
                        self.ref.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":"","Status":"Active","Subscription":0])
                        
                    } else if self.authProvider == "Email" {
                        
                        let name: String = self.emailAuthName
                        let email: String = self.emailAuthEmail
                        self.uid = user.uid as String
                        
                        self.ref.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":"","Status":"Active","Subscription":0])
                    }
            
                }*/
                
            })
            
            
        }

    }
    
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        
        try! FIRAuth.auth()!.signOut()
        
        FBSDKAccessToken.setCurrent(nil)
        
        self.ref.child("Users").child(self.uid).child("Status").setValue("Inactive")
        
        self.performSegue(withIdentifier: "goToMapView", sender: self)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nameFieldChanged(_ sender: AnyObject) {
        
        let nameFieldText = self.nameField.text! as String
        
        self.ref.child("Users").child(self.uid).child("Name").setValue(nameFieldText)
        
    }

    @IBAction func emailFieldChanged(_ sender: AnyObject) {
        
        let emailFieldText = self.emailField.text! as String
        
        self.ref.child("Users").child(self.uid).child("Email").setValue(emailFieldText)
        
    }
    
    @IBAction func phoneFieldChange(_ sender: AnyObject) {
        
        let phoneFieldText = self.phoneField.text! as String
        
        self.ref.child("Users").child(self.uid).child("Phone").setValue(phoneFieldText)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        print("ShouldChange was called")
        if (textField == phoneField)
        {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
        }
        else
        {
            return true
        }
    }

}
