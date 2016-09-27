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
                    
                    if self.authProvider == "Facebook" {
                        let name: String = user.displayName! as String
                        let email: String = user.email! as String
                        self.uid = user.uid as String
                    self.ref.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":"","Status":"Active"])
                    }
            
                }
                
            })
            
            
        } else {
            
            //no one is signed in
            
        }

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func didTapLogout(sender: UIButton) {
        // signs user out of Firebase
        try! FIRAuth.auth()!.signOut()
        
        // signs user out of Facebook app
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        //let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
        //let accountViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("accountView")
        
        self.ref.child("Users").child(self.uid).child("Status").setValue("Inactive")
        self.performSegueWithIdentifier("unwindLogin", sender: self)
        
        //self.presentViewController(accountViewController, animated: true, completion: nil)
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        print("ShouldChange was called")
        if (textField == phoneField)
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
        }
        else
        {
            return true
        }
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
