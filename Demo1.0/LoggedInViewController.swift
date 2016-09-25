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

class LoggedInViewController: UIViewController {

    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
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
            let name: String = user.displayName! as String
            let email: String = user.email! as String
            let uid: String = user.uid as String
            
            let storage = FIRStorage.storage()
            
            let storageRef = storage.referenceForURL("gs://nrgapp-36548.appspot.com")
            
            self.ref.child("Users").child(uid).setValue(["Name":name,"Email":email])
            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
