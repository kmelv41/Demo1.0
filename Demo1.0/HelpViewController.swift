//
//  HelpViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit

class HelpViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    var selectedIndex : IndexPath?
    
    var tableData = [["Question": "Question1", "Answer": "Answer1"], ["Question": "Where do I find a Wharf?  Do I always have to return it to the same location I rented it from?", "Answer": "They are located at several locations: cafes, restaurants, transit stations, casinos, bars and hotels.  Just walk into a Wharf location and ask staff at that venue where to find one."]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        print(tableData[0])
        print(tableData[0]["Question"])
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedIndex != indexPath {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hiddenCell", for: indexPath) as! FAQTableViewCell
            
            cell.questionLabel.text = self.tableData[indexPath.row]["Question"]
            
            cell.questionLabel.lineBreakMode = .byWordWrapping
            cell.questionLabel.numberOfLines = 0
            
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FAQTableViewCell
            
            cell.questionLabel.text = self.tableData[indexPath.row]["Question"]
            cell.answerLabel.text = self.tableData[indexPath.row]["Answer"]
            
            cell.questionLabel.lineBreakMode = .byWordWrapping
            cell.questionLabel.numberOfLines = 0
            cell.answerLabel.lineBreakMode = .byWordWrapping
            cell.answerLabel.numberOfLines = 0
            
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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

}
