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
    var filteredArray: [[String?]] = []
    var tableArray = [[String?]]()
    
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
        tableArray = createArrays(items)
        self.listTableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        /*self.filteredArray = searchArray.filter({(names: String) -> Bool in
            return names.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })*/
        
        self.filteredArray = tableArray.filter { (dataArray:[String?]) -> Bool in
            return dataArray.filter({ (string) -> Bool in
                return string!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            }).count > 0
        }
        
        if searchText != "" {
            shouldShowSearchResults = true
        } else {
            shouldShowSearchResults = false
        }
        self.listTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return tableArray.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Retrieve cell
        let myCell = tableView.dequeueReusableCellWithIdentifier("BasicCell")! as! CustomVenueCell
        let item: LocationModel = feedItems[indexPath.row] as! LocationModel
        let pinLocation = CLLocation(latitude: Double(item.latitude!)!, longitude: Double(item.longitude!)!)
        currentLocation = locationManager.location
        let distFromPin: Double = currentLocation.distanceFromLocation(pinLocation)/1000
        _ = item.name
        _ = "\(String(format:"%.1f",distFromPin)) km"
        _ = item.address
        _ = item.city
        
        if shouldShowSearchResults {
            let row = indexPath.row
            myCell.venueLabel.text = filteredArray[row][0]
            myCell.distanceLabel.text = filteredArray[row][3]! + " km"
            myCell.addressLabel.text = filteredArray[row][1]
            myCell.cityLabel.text = filteredArray[row][2]
            return myCell
        } else {
            let row = indexPath.row
            myCell.venueLabel.text = tableArray[row][0]
            myCell.distanceLabel.text = tableArray[row][3]! + " km"
            myCell.addressLabel.text = tableArray[row][1]
            myCell.cityLabel.text = tableArray[row][2]
            return myCell
        }
    }
    
    func createArrays (initialData: NSArray) -> [[String?]] {
        // test code
        var newArray = [[String?]]()
        for index in 0..<initialData.count {
            var singleRecord = [String?]()
            let pinLocation = CLLocation(latitude: Double(initialData[index].latitude!!)!, longitude: Double(initialData[index].longitude!!)!)
            currentLocation = locationManager.location
            let distFromPin: Double = currentLocation.distanceFromLocation(pinLocation)/1000
            let strFromPin = String(format:"%.1f",distFromPin)
            singleRecord.append(initialData[index].name)
            singleRecord.append(initialData[index].address)
            singleRecord.append(initialData[index].city)
            singleRecord.append(strFromPin)
            newArray.append(singleRecord)
        }
        let sortedArray = newArray.sort { $0[3] < $1[3] }
        return sortedArray
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

