//
//  HamburgerViewController.swift
//  Demo1.0
//
//  Created by User on 2016-11-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit

class HamburgerViewController : UITableViewController {
    
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        self.tableView.isScrollEnabled = false
        
        reachability.whenUnreachable = { reachability in
            
            self.performSegue(withIdentifier: "segueToMapNoConnection", sender: self)
            
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.revealViewController().frontViewController.view.isUserInteractionEnabled = false
        self.revealViewController().view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.revealViewController().frontViewController.view.isUserInteractionEnabled = true
    }
    
}
