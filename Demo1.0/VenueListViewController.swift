//
//  ViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class VenueListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    //Properties
    
    // NOTES for Firebase Pull
    // Each data point (i.e. each venue) is an array of dictionaries
    // Therefore, the entire data set is an array of an array of dictionaries...
    // ... which is essentially the multidimensinal array I was working with previously
    // I should pull each venue and append them into an array, and then...
    // ... format that array as "TableArray" like I did previously
    
    var feedItems: NSArray = NSArray()
    var fbaseItems: NSArray = NSArray()
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var currentLocation : CLLocation! = nil
    var locationManager = CLLocationManager()
    let searchBar = UISearchBar()
    var filteredArray = [[String?]]()
    var tableArray = [[String?]]()
    let rootRef = FIRDatabase.database().reference()
    var routeLatitude = Double()
    var routeLongitude = Double()
    
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
        
        // let homeModel = HomeModel()
        // homeModel.delegate = self
        // homeModel.downloadItems()
        
        let venueRef = rootRef.child("venues")
        venueRef.observeEventType(.Value, withBlock: { snapshot in
            
            var dataPull = snapshot.value! as! [[String:String]]
            
            var newArray: [[String?]] = [[String?]]()
            for index in 0..<dataPull.count {
                var singleRecord = [String?]()
                singleRecord.append(dataPull[index]["Name"])
                singleRecord.append(dataPull[index]["Address"])
                singleRecord.append(dataPull[index]["City"])
                singleRecord.append(dataPull[index]["Latitude"])
                singleRecord.append(dataPull[index]["Longitude"])
                let pinLocation = CLLocation(latitude: Double(singleRecord[3]!)!, longitude: Double(singleRecord[4]!)!)
                self.currentLocation = self.locationManager.location
                let distFromPin: Double = self.currentLocation.distanceFromLocation(pinLocation)/1000
                let strFromPin = String(format:"%.1f",distFromPin)
                singleRecord.append(strFromPin)
                newArray.append(singleRecord)
            }
            self.tableArray = newArray.sort { Float($0[5]!) < Float($1[5]!) }

            self.listTableView.reloadData()

        })
        
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
    
    // already commented out
    /*func itemsDownloaded(items: NSArray) {
        
        feedItems = items
        self.listTableView.reloadData()
    }*/
    
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
        
        myCell.directionsButton.tag = indexPath.row
        
        myCell.directionsButton.addTarget(self, action: #selector(VenueListViewController.logAction(_:)), forControlEvents: .TouchUpInside)
        
        /*let item: LocationModel = feedItems[indexPath.row] as! LocationModel
        let pinLocation = CLLocation(latitude: Double(item.latitude!)!, longitude: Double(item.longitude!)!)
        currentLocation = locationManager.location
        let distFromPin: Double = currentLocation.distanceFromLocation(pinLocation)/1000
        _ = item.name
        _ = "\(String(format:"%.1f",distFromPin)) km"
        _ = item.address
        _ = item.city*/
        
        if shouldShowSearchResults {
            let row = indexPath.row
            myCell.venueLabel.text = filteredArray[row][0]
            myCell.distanceLabel.text = filteredArray[row][5]! + " km"
            myCell.addressLabel.text = filteredArray[row][1]
            myCell.cityLabel.text = filteredArray[row][2]
            return myCell
        } else {
            let row = indexPath.row
            myCell.venueLabel.text = tableArray[row][0]
            myCell.distanceLabel.text = tableArray[row][5]! + " km"
            myCell.addressLabel.text = tableArray[row][1]
            myCell.cityLabel.text = tableArray[row][2]
            return myCell
        }
    }
    
    // issue is in createArrays function
    /*func createArrays (initialData: NSArray) -> [[String?]] {
        // test code
        var newArray: [[String?]] = [[String?]]()
        for index in 0..<initialData.count {
            // var singleRecord: [String?] = [String?]()
            var singleRecord = [String?]()
            singleRecord.append(initialData[index]["Name"])
            singleRecord.append(initialData[index]["Address"])
            singleRecord.append(initialData[index]["City"])
            singleRecord.append(initialData[index]["Latitude"])
            singleRecord.append(initialData[index]["Longitude"])
            let pinLocation = CLLocation(latitude: Double(singleRecord[3]!!)!, longitude: Double(singleRecord[4]!!)!)
            currentLocation = locationManager.location
            let distFromPin: Double = currentLocation.distanceFromLocation(pinLocation)/1000
            let strFromPin = String(format:"%.1f",distFromPin)
            singleRecord.append(strFromPin)
            newArray.append(singleRecord)
        }
        let sortedArray = newArray.sort { Float($0[5]!) < Float($1[5]!) }
        return sortedArray
    }*/
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        self.listTableView.reloadData()
    }
    
    @IBAction func logAction(sender: UIButton) {
        let index = sender.tag
        if shouldShowSearchResults {
            routeLatitude = Double(filteredArray[index][3]!)!
            routeLongitude = Double(filteredArray[index][4]!)!
        } else {
            routeLatitude = Double(tableArray[index][3]!)!
            routeLongitude = Double(tableArray[index][4]!)!
        }
        
        self.performSegueWithIdentifier("myUnwindSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "myUnwindSegue" {
            let destViewController : MapViewController = segue.destinationViewController as! MapViewController
            
            destViewController.routeLat = routeLatitude
            destViewController.routeLong = routeLongitude
            
            destViewController.makeRoute(routeLatitude,longitude: routeLongitude)
            
        }
        
    }
    
}

