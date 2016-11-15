//
//  HamburgerViewController.swift
//  Demo1.0
//
//  Created by User on 2016-11-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit

class HamburgerViewController : UITableViewController {
    
    override func viewDidLoad() {
        self.tableView.isScrollEnabled = false
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
