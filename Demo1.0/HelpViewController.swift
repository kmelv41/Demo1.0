//
//  HelpViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import Firebase

class HelpViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    var selectedIndex : IndexPath?
    let rootRef = FIRDatabase.database().reference()
    
    var tableData = [[String:String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let FAQRef = rootRef.child("FAQ")
        FAQRef.observe(.value, with: { snapshot in
            
            self.tableData = snapshot.value! as! [[String:String]]
            
            self.tableView.reloadData()
            
        })
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count + 1
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell", for: indexPath)
            
            return cell
            
        } else {
            
            if selectedIndex != indexPath {
                let cell = tableView.dequeueReusableCell(withIdentifier: "hiddenCell", for: indexPath) as! FAQTableViewCell
                
                cell.questionLabel.text = self.tableData[indexPath.row-1]["Question"]
                
                cell.questionLabel.lineBreakMode = .byWordWrapping
                cell.questionLabel.numberOfLines = 0
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FAQTableViewCell
                
                cell.questionLabel.text = self.tableData[indexPath.row-1]["Question"]
                cell.answerLabel.text = self.tableData[indexPath.row-1]["Answer"]
                
                cell.questionLabel.lineBreakMode = .byWordWrapping
                cell.questionLabel.numberOfLines = 0
                cell.answerLabel.lineBreakMode = .byWordWrapping
                cell.answerLabel.numberOfLines = 0
                
                return cell
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            let url = NSURL(string: "mailto:info@findawharf.com")
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            }
            else
            {
                UIApplication.shared.openURL(url as! URL)
            }
            
        } else {
            
            let previousIndexPath = selectedIndex
            
            var multiPaths = [IndexPath]()
            
            if selectedIndex == indexPath {
                selectedIndex = nil
            } else {
                selectedIndex = indexPath
            }
            
            if let previous = previousIndexPath {
                multiPaths.append(previous)
            }
            if let current = selectedIndex {
                multiPaths.append(current)
            }
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: multiPaths, with: .automatic)
            self.tableView.endUpdates()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

}
