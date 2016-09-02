//
//  ViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HomeModelProtocol, UISearchBarDelegate, UISearchDisplayDelegate  {
    
    //Properties
    
    var feedItems: NSArray = NSArray()
    var selectedLocation : LocationModel = LocationModel()
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var currentLocation : CLLocation! = nil
    var locationManager = CLLocationManager()
    let searchBar = UISearchBar()
    var filteredArray: NSArray = NSArray()
    var displayedArray = [String]()
    var searchArray = [String] ()
    
    var shouldShowSearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        
        //set delegates and initialize homeModel
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        
        self.listTableView.delegate = self
        self.listTableView.dataSource = self
        
        let homeModel = HomeModel()
        homeModel.delegate = self
        homeModel.downloadItems()
        
    }
    
    func createSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search Venues"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }
    

    @IBAction func mapButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("myUnwindSegue", sender: self)
    }
    
    func itemsDownloaded(items: NSArray) {
        
        feedItems = items
        self.listTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filteredArray = searchArray.filter({(names: String) -> Bool in
            return names.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
        
        if searchText != "" {
            shouldShowSearchResults = true
            self.listTableView.reloadData()
        } else {
            shouldShowSearchResults = false
            self.listTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return feedItems.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Retrieve cell
        let cellIdentifier: String = "BasicCell"
        let myCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as! CustomVenueCell
        
        if shouldShowSearchResults {
            myCell.textLabel!.text = filteredArray[indexPath.row] as? String
            return myCell
        } else {
            let item: LocationModel = feedItems[indexPath.row] as! LocationModel
            let pinLocation = CLLocation(latitude: Double(item.latitude!)!, longitude: Double(item.longitude!)!)
            currentLocation = locationManager.location
            let distFromPin: Double = currentLocation.distanceFromLocation(pinLocation)/1000
            myCell.venueLabel.text = item.name
            myCell.distanceLabel.text = "\(String(format:"%.1f",distFromPin)) km"
            
            // old text reference
            //myCell.textLabel!.text = item.name! + " - \(String(format:"%.1f",distFromPin)) km away"
            
            // lines for Search Function
            /*searchArray.append(myCell.textLabel!.text!)
            searchArray = Array(Set(searchArray))*/
            return myCell
        }
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        self.listTableView.reloadData()
    }
    
}

