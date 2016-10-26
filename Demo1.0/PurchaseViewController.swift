//
//  PurchaseViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import Stripe
import AFNetworking

class PurchaseViewController: UIViewController {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var monthExpiration: UITextField!
    @IBOutlet weak var yearExpiration: UITextField!
    @IBOutlet weak var CVCNumber: UITextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        
        let stripeCard = STPCardParams()
        
        if self.monthExpiration.text?.isEmpty == false && self.yearExpiration.text?.isEmpty == false {
            let numMonth = UInt(self.monthExpiration.text!)!
            let numYear = UInt(self.yearExpiration.text!)!
            
            stripeCard.number = self.cardNumber.text
            stripeCard.cvc = self.CVCNumber.text
            stripeCard.expMonth = numMonth
            stripeCard.expYear = numYear
            
        }
        
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
        
    }
    
    func handleError() {
        
        let alertController = UIAlertController(title: "Please Try Again", message: "Some information was missing or incorrect.", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func postStripeToken(token: STPToken) {
        
        print("Token ID is \(token.tokenId)")

        var request = URLRequest(url: NSURL(string: "http://findawharf.com/premium_charge.php")! as URL)
        
        request.httpMethod = "POST"
        
        let postString = "stripeToken=\(token.tokenId)&stripeEmail=kevin@iosfake.com"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("response is \(responseString)")
            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
