//
//  OurTableViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import FirebaseAuth

class AccountViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    let loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        self.loginButton.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                let loggedInViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loggedInView")
                
                self.presentViewController(loggedInViewController, animated: true, completion: nil)
                
            } else {
                // No user is signed in.
                // show user login button.
                
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
                self.view.addSubview(self.loginButton)
                 
                self.loginButton.hidden = false
            }
        }

    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User logged in")
        
        self.loginButton.hidden = true
        
        if(error != nil) {
            
            self.loginButton.hidden = false
            
        } else if(result.isCancelled) {
            
            self.loginButton.hidden = false
            
        } else {
        
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            print("User logged into Firebase")
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }

    // All remaining code is the default Swift code
    
    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
