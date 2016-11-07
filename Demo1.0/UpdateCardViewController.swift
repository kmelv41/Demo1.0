//
//  UpdateCardViewController.swift
//  Demo1.0
//
//  Created by User on 2016-11-06.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import Stripe

class UpdateCardViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    
    
    let paymentTextField = STPPaymentCardTextField()
    
    override func viewDidLoad() {
        
        paymentTextField.frame = CGRect(x: 15, y: self.view.frame.height/2 - 50, width: self.view.frame.width - 30, height: 44)
        
        paymentTextField.backgroundColor = UIColor.white
        
        updateButton.frame = CGRect(x: 15, y: self.view.frame.height/2, width: self.view.frame.width - 30, height: 44)
        
        cancelButton.frame = CGRect(x: 15, y: self.view.frame.height/2 + 50, width: self.view.frame.width - 30, height: 44)
        
        updateButton.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 15
        
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        
        self.updateButton.isHidden = true
        
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.valid {
            self.updateButton.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "updateUnwind" {
            
            let destViewController : SubscribedViewController = segue.destination as! SubscribedViewController
            
            destViewController.stripeCard = self.paymentTextField.cardParams
            
            destViewController.successfulUpdate()
            
        }
    }
    
}
