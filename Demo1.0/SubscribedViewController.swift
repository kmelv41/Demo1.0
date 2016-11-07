//
//  SubscribedViewController.swift
//  Demo1.0
//
//  Created by User on 2016-11-04.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import Stripe
import Firebase

class SubscribedViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var cancelSubscription: UIButton!
    @IBOutlet weak var updateCard: UIButton!
    var previouslySubscribed = false
    var stripeCard = STPCardParams()
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var userEmail = ""
    var stripeID = ""
    var uid: String = ""
    let disGroup = DispatchGroup()
    let rootRef = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        updateCard.layer.cornerRadius = 15
        cancelSubscription.layer.cornerRadius = 15
        
        headlineLabel.lineBreakMode = .byWordWrapping
        headlineLabel.numberOfLines = 0
        
        if previouslySubscribed {
            self.headlineLabel.text = "You are currently subscribed to our monthly membership, you can rent a Wharf at no charge anytime."
        }
        
        if (FIRAuth.auth()?.currentUser) != nil {
            self.uid = (FIRAuth.auth()?.currentUser?.uid)!
            
            self.disGroup.enter()
            
            self.rootRef.child("Users").child(self.uid).observeSingleEvent(of: .value, with: { snapshot in
                
                let dataPull = snapshot.value! as! [String:AnyObject]
                
                if snapshot.hasChild("Email") {
                    self.userEmail = (dataPull["Email"]! as? String)!
                }
                
                if snapshot.hasChild("StripeID") {
                    self.stripeID = (dataPull["StripeID"]! as? String)!
                }
                
                self.disGroup.leave()
                
            })
            
            self.disGroup.notify(queue: DispatchQueue.main, execute: {
                
                print("Firebase pull is finished.")
                
            })
            
        } else {
            
            // no user is logged in
            
        }
        
    }
    
    @IBAction func unwindToSubscribed(_ sender: UIStoryboardSegue) {
        // nothing to do
    }

    
    @IBAction func updateCardTapped(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "UpdatePopover", sender: self)
        
    }
    
    @IBAction func cancelSubscriptionTapped(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Are you sure you want to cancel your subscription?", message: "", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.progressBarDisplayer("Processing", true)
            self.cancelPlan()
            
        })
        
        let altAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(altAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "UpdatePopover" {
            
            let vc : UpdateCardViewController = segue.destination as! UpdateCardViewController
            
            let controller = vc.popoverPresentationController
            
            controller?.sourceView = self.view
            
            controller?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            
            controller?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            if controller != nil {
                controller?.delegate = self
            }

        }
    }
    
    func successfulUpdate() {
        
        self.progressBarDisplayer("Processing", true)
        
        if STPCardValidator.validationState(forCard: self.stripeCard) == .valid {
            STPAPIClient.shared().createToken(withCard: self.stripeCard, completion: { (token,error) -> Void in
                if error != nil {
                    self.handleError()
                    return
                }
                
                self.postStripeToken(token: token!)
            })
        } else {
            self.handleError()
        }
        
        
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
        
        let dGroup = DispatchGroup()
        
        print("Token ID is \(token.tokenId)")
        
        dGroup.enter()
        
        var request = URLRequest(url: NSURL(string: "http://findawharf.com/premium_update.php")! as URL)
        
        request.httpMethod = "POST"
        
        let postString = "stripeToken=\(token.tokenId)&stripeEmail=\(self.userEmail)&customerID=\(self.stripeID)"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                self.handleError()
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            print("response is \(responseString)")
            
            let data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            
            dGroup.leave()
                
            dGroup.notify(queue: DispatchQueue.main, execute: {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: AnyObject]
                    
                    if let status = json["status"] as? String {
                        if let message = json["message"] as? String {
                            print(message)
                            print(status)
                            
                            self.activityIndicator.isHidden = true
                            self.strLabel.isHidden = true
                            self.messageFrame.isHidden = true
                            
                            let alertController = UIAlertController(title: status, message: message, preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
            })
            
        }
        
        task.resume()
        
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

    func cancelPlan() {
        
        let dGroup = DispatchGroup()
        
        dGroup.enter()
        
        var request = URLRequest(url: NSURL(string: "http://findawharf.com/premium_cancel.php")! as URL)
        
        request.httpMethod = "POST"
        
        let postString = "customerID=\(self.stripeID)"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                self.handleError()
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
                        
                        if status == "Success" {
                            
                            self.rootRef.child("Users").child(self.uid).updateChildValues(["Subscription":0])
                            
                            
                        }
                        
                        dGroup.leave()
                        
                        dGroup.notify(queue: DispatchQueue.main, execute: {
                            
                            let alertController = UIAlertController(title: status, message: message, preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            
                            alertController.addAction(defaultAction)
                            
                            self.activityIndicator.isHidden = true
                            self.strLabel.isHidden = true
                            self.messageFrame.isHidden = true
                            
                            self.present(alertController, animated: true, completion: nil)

                            
                        })
                        
                    }
                    
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        
        task.resume()

        
    }
    
}
