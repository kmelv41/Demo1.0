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
import GoogleSignIn

class AccountViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    // add new login options
    // organize buttons
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    let loginButton = FBSDKLoginButton()
    var authProvider = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self

        self.loginButton.delegate = self
        self.loginButton.center = self.containerView.center
        //self.loginButton.hidden = true
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                
                self.performSegueWithIdentifier("loginSegue", sender: self)
                
                // original segue code
                //let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                //let loggedInViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loggedInView")
                
                //self.presentViewController(loggedInViewController, animated: true, completion: nil)
                
            } else {
                // No user is signed in.
                // show user login button.
                
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                //self.loginButton.hidden = false
                self.loginButton.center = self.containerView.center
                self.view.addSubview(self.loginButton)

            }
        }

    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User logged in")
        
        //self.loginButton.hidden = true
        self.loginButton.center = self.containerView.center
        
        if(error != nil) {
            
            self.loginButton.center = self.containerView.center
            //self.loginButton.hidden = false
            
        } else if(result.isCancelled) {
            
            self.loginButton.center = self.containerView.center
            //self.loginButton.hidden = false
            
        } else {
        
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            print("User logged into Firebase")
            }
            self.authProvider = "Facebook"
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
    
    @IBAction func signInTapped(sender: UIButton) {
        
        self.login()
        
    }
    
    @IBAction func signUpTapped(sender: UIButton) {
        FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!, completion: {
            user, error in
            
            if error != nil {
                
                self.authProvider = "Email"
                self.login()
                
            } else {
                print("User created")
                self.authProvider = "Email"
                self.login()
            }
            
        })
    }
    
    func login() {
        FIRAuth.auth()?.signInWithEmail(emailField.text!, password: passwordField.text!, completion: {
            user, error in
            
            if error != nil {
                
                print("Incorrect email or password")
                
            } else {
                
                print("User logged in with email")
                
            }
            
            
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSegue" {
            
            let destViewController : LoggedInViewController = segue.destinationViewController as! LoggedInViewController
            
            destViewController.authProvider = self.authProvider
            
            if self.authProvider == "Email" {
                destViewController.emailAuthEmail = emailField.text!
                destViewController.emailAuthName = firstNameField.text! + " " + lastNameField.text!
            }
            
        }
    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
        self.loginButton.center = self.containerView.center
        self.view.addSubview(self.loginButton)
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user,error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            print("User logged in with Google")
            
        })
        
        self.authProvider = "Google"
        
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        try! FIRAuth.auth()!.signOut()
        
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
