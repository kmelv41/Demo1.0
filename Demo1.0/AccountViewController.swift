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

class AccountViewController: UIViewController {
    
    // add new login options
    // organize buttons
    
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var accountExists: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var authProvider = String()
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var loginWorked = false
    var currentCustomer = false
    var uid = String()
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        
        signUpButton.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 15
        accountExists.layer.cornerRadius = 15
        

    }
    
    @IBAction func signUpButtonTapped(_ sender: AnyObject) {
        
        progressBarDisplayer("Logging In", true)
        
        var fieldList = String()
        
        var emptyFields = [String]()
        
        if currentCustomer {
            
            self.login()
            
        } else {
            
            if emailField.text == "" {
                emptyFields.append("Email")
            }
            
            if passwordField.text == "" {
                emptyFields.append("Password")
            }
            
            if firstNameField.text == "" {
                emptyFields.append("First Name")
            }
            
            if lastNameField.text == "" {
                emptyFields.append("Last Name")
            }
            
            if emptyFields.count == 0 {
                
                FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: {
                    user, error in
                    
                    if error != nil {
                        
                        self.login()
                        
                    } else {
                        print("User created")
                        self.login()
                    }
                    
                    self.messageFrame.isHidden = true
                    self.activityIndicator.isHidden = true
                    self.strLabel.isHidden = true
                    
                })
                
            } else {
                
                var x = 0
                
                for fields in emptyFields {
                    
                    fieldList.append(fields)
                    
                    x+=1
                    
                    if x < emptyFields.count {
                        fieldList.append(", ")
                    }
                    
                }
                
                self.messageFrame.isHidden = true
                self.activityIndicator.isHidden = true
                self.strLabel.isHidden = true
                
                let alertController = UIAlertController(title: "Please fill out all fields", message: "The following fields are missing: \(fieldList).", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
    
    @IBAction func accountExistsTapped(_ sender: AnyObject) {
        
        if currentCustomer {
            
            self.currentCustomer = false
            
            self.progressBarDisplayer("Updating", true)
            
            self.perform(#selector(AccountViewController.hideActivityIndicator), with: nil, afterDelay: 1.0)
            
            self.firstNameField.isHidden = false
            self.lastNameField.isHidden = false
            self.instructionLabel.isHidden = false
            self.signUpButton.setTitle("Sign Up", for: .normal)
            self.accountExists.setTitle("I already have an account!", for: .normal)
            
        } else {
            
            self.currentCustomer = true
            
            self.progressBarDisplayer("Updating", true)
            
            self.perform(#selector(AccountViewController.hideActivityIndicator), with: nil, afterDelay: 1.0)
            
            self.firstNameField.isHidden = true
            self.lastNameField.isHidden = true
            self.instructionLabel.isHidden = true
            self.signUpButton.setTitle("Sign In", for: .normal)
            self.accountExists.setTitle("I don't have an account yet!", for: .normal)
            
        }
    
    }
    
    func hideActivityIndicator() {
        
        self.activityIndicator.stopAnimating()
        self.strLabel.isHidden = true
        self.messageFrame.isHidden = true
        self.activityIndicator.isHidden = true
        
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "backToMap", sender: self)
        
    }
    
    func login() {
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: {
            user, error in
            
            if self.currentCustomer {
                
                if error != nil {
                    
                    print("Incorrect email or password")
                    
                    self.messageFrame.isHidden = true
                    self.activityIndicator.isHidden = true
                    self.strLabel.isHidden = true
                    
                    let alertController = UIAlertController(title: "Incorrect Email or Password", message: "Please try again.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)

                    
                } else {
                    
                    print("User logged in with email")
                    self.loginWorked = true
                    self.performSegue(withIdentifier: "backToMap", sender: self)
                    
                }
                
            } else {
                
                if error != nil {
                    
                    print("Incorrect email or password")
                    
                    self.messageFrame.isHidden = true
                    self.activityIndicator.isHidden = true
                    self.strLabel.isHidden = true
                    
                    let alertController = UIAlertController(title: "Oops", message: "Something went wrong, please try again.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    
                    let disGroup = DispatchGroup()
                    
                    disGroup.enter()
                    
                    let name: String = self.firstNameField.text! + " " + self.lastNameField.text!
                    let email: String = self.emailField.text!
                    self.uid = (user?.uid)! as String
                    
                    self.ref.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":"","Status":"Active","Subscription":0])
                    
                    disGroup.leave()
                    
                    disGroup.notify(queue: DispatchQueue.main, execute: {
                        
                        self.performSegue(withIdentifier: "backToMap", sender: self)
                        
                    })
                    
                }
                
            }
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMap" {
            //nothing yet
        }
    }
    
    func progressBarDisplayer(_ msg:String, _ indicator:Bool ) {
        print(msg)
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
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
