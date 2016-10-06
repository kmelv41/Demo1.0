//
//  PurchaseViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import Stripe

class PurchaseViewController: UIViewController {

    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    @IBOutlet weak var monthExpiration: UITextField!
    @IBOutlet weak var yearExpiration: UITextField!
    @IBOutlet weak var CVCNumber: UITextField!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    let STRIPE_TEST_PUBLIC_KEY = "pk_test_EskqahNjPK5JfRSt2pf4wTG3"
    let STRIPE_TEST_POST_URL = ""
    
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
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func postStripeToken(token: STPToken) {
        
        print("Token ID is \(token.tokenId)")
        
    }
    
    /*func validateCustomerInfo() -> Bool {
        var alert = UIAlertView(title: "Please try again", message: "Please enter all required information", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
        //1. Validate name & email
        if (self.nameTextField.text?.isEmpty)! {
            alert.show()
            return false
        }
        
        //2. Validate card number, CVC, expMonth, expYear
        let error: Error? = nil
        try self.stripeCard.validateCardReturningError()
        //3
        if error != nil {
            alert.message! = error!.localizedDescription
            alert.show()
            return false
        }
        return true

    }
    
    func performStripeOperation() {
        //1
        self.completeButton.isEnabled = false
        //2

        Stripe.createToken(with: self.stripeCard, publishableKey: STRIPE_TEST_PUBLIC_KEY, completion: {(token: STPToken, error: Error) -> Void in
            if error {
                self.handleStripeError(error)
            }
            else {
                self.postStripeToken(token.tokenId)
            }
        })
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
