//
//  PurchaseViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import Stripe
import Firebase

class PurchaseViewController: UIViewController, STPPaymentCardTextFieldDelegate {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    //var userEmail: String = ""
    var userEmail: String = ""
    var stripeID: String = ""
    var alreadyAlerted: Bool = false
    var subscribed: Int = 0
    var uid: String = ""
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()

    
    let paymentTextField = STPPaymentCardTextField()
    
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        
        if (FIRAuth.auth()?.currentUser) != nil {
            self.uid = (FIRAuth.auth()?.currentUser?.uid)!
        } else {
            // No user is signed in.
        }

        paymentTextField.frame = CGRect(x: 15, y: self.view.frame.height/2 - 50, width: self.view.frame.width - 30, height: 44)
        
        completeButton.frame = CGRect(x: 15, y: self.view.frame.height/2, width: self.view.frame.width - 30, height: 44)
        
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        self.completeButton.isHidden = true
        
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.valid {
            self.completeButton.isHidden = false
        }
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        
        paymentTextField.endEditing(true)
        
        progressBarDisplayer("Processing", true)
        
            self.rootRef.child("Users").child(self.uid).observe(.value, with: { snapshot in
                
                let dataPull = snapshot.value! as! [String:AnyObject]
                
                if snapshot.hasChild("Email") {
                    self.userEmail = (dataPull["Email"]! as? String)!
                }
                
                if snapshot.hasChild("StripeID") {
                    self.stripeID = (dataPull["StripeID"]! as? String)!
                }
                
                if snapshot.hasChild("Subscription") {
                    self.subscribed = (dataPull["Subscription"]! as? Int)!
                }
                
                if self.subscribed == 1 {
                    
                    let alertController = UIAlertController(title: "You are already subscribed.", message: "", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    
                    self.activityIndicator.isHidden = true
                    self.strLabel.isHidden = true
                    self.messageFrame.isHidden = true
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                let stripeCard = self.paymentTextField.cardParams
                
                /*
                 if self.monthExpiration.text?.isEmpty == false && self.yearExpiration.text?.isEmpty == false {
                 let numMonth = UInt(self.monthExpiration.text!)!
                 let numYear = UInt(self.yearExpiration.text!)!
                 
                 stripeCard.number = self.cardNumber.text
                 stripeCard.cvc = self.CVCNumber.text
                 stripeCard.expMonth = numMonth
                 stripeCard.expYear = numYear
                 
                 }*/
                
                if STPCardValidator.validationState(forCard: stripeCard) == .valid {
                    STPAPIClient.shared().createToken(withCard: stripeCard, completion: { (token,error) -> Void in
                        if error != nil {
                            self.handleError()
                            return
                        }
                        
                        self.postStripeToken(token: token!)
                    })
                } else {
                    self.handleError()
                }
                
            })
        
    }
    
    func handleError() {
        
        let alertController = UIAlertController(title: "Please Try Again", message: "Some information was missing or incorrect.", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        
        self.activityIndicator.isHidden = true
        self.strLabel.isHidden = true
        self.messageFrame.isHidden = true
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func postStripeToken(token: STPToken) {
        
        print("Token ID is \(token.tokenId)")
        
        var postString: String = ""

        var request = URLRequest(url: NSURL(string: "http://findawharf.com/premium_charge.php")! as URL)
        
        request.httpMethod = "POST"
        
        if self.stripeID != "" {
            postString = "stripeToken=\(token.tokenId)&stripeEmail=\(self.userEmail)&customerID=\(self.stripeID)"
        } else {
            postString = "stripeToken=\(token.tokenId)&stripeEmail=\(self.userEmail)&customerID=\(self.stripeID)"
        }
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            print("response is \(responseString)")
            
            let data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                
                if let status = json["status"] as? String {
                    if let message = json["message"] as? String {
                        print(message)
                        print(status)
                        
                        if self.alreadyAlerted == false {
                            
                            let alertController = UIAlertController(title: status, message: message, preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            
                            alertController.addAction(defaultAction)
                            
                            self.alreadyAlerted = true
                            
                            self.activityIndicator.isHidden = true
                            self.strLabel.isHidden = true
                            self.messageFrame.isHidden = true
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                            if let newStripeID = json["stripeID"] as? String {
                                
                                if status == "Success" {
                                    
                                    self.rootRef.child("Users").child(self.uid).updateChildValues(["Subscription":1])
                                    
                                    self.rootRef.child("Users").child(self.uid).updateChildValues(["StripeID":newStripeID])
                                }
                                
                            }
                        }
                        
                    }
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            self.activityIndicator.isHidden = true
            self.strLabel.isHidden = true
            self.messageFrame.isHidden = true
            
        }
        
        task.resume()
        
        
        /*let URL = "http://findawharf.com/premium_charge.php"
        let params = ["stripeToken": token.tokenId,
                      "stripeEmail": "kevin@iosfake.com"] as NSDictionary
        
        let manager = AFHTTPSessionManager()
        manager.post(URL, parameters: params, progress: nil, success: { (operation, responseObject) -> Void in
            
            if let response = responseObject as? [String: String] {
                
                let alertController = UIAlertController(title: response["status"], message: response["message"], preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)

            }
            
        }) { (operation, error) -> Void in
            self.handleError()
        }*/
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
