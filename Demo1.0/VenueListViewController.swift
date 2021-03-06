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

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class VenueListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIPopoverPresentationControllerDelegate {
    
    //Properties
    
    // NOTES for Firebase Pull
    // Each data point (i.e. each venue) is an array of dictionaries
    // Therefore, the entire data set is an array of an array of dictionaries...
    // ... which is essentially the multidimensinal array I was working with previously
    // I should pull each venue and append them into an array, and then...
    // ... format that array as "TableArray" like I did previously
    
    @IBOutlet weak var filterButton: UIButton!
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
    var segueArray = [String?]()
    var categoryArray = [String]()
    var criteriaArray = [[String?]]()
    var filterBool = false
    var fullArray = [[String?]]()
    
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
        venueRef.observe(.value, with: { snapshot in
            
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
                let distFromPin: Double = self.currentLocation.distance(from: pinLocation)/1000
                let strFromPin = String(format:"%.1f",distFromPin)
                singleRecord.append(strFromPin)
                singleRecord.append(dataPull[index]["Category"])
                newArray.append(singleRecord)
            }
            self.tableArray = newArray.sorted { Float($0[5]!) < Float($1[5]!) }
            self.fullArray = newArray.sorted { Float($0[5]!) < Float($1[5]!) }

            self.listTableView.reloadData()

        })
        
    }
    
    func createSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search Venues"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
    }

    @IBAction func mapButtonClicked(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "myUnwindSegue", sender: self)
    }
    
    @IBAction func unwindToVenues(_ sender: UIStoryboardSegue) {
        if filterBool == true {
            
            self.criteriaArray = [[String?]]()

            self.filterBool = false
            
            for cat in categoryArray {
                
                for venue in fullArray {
                    
                    if venue[6]! == cat {
                        
                        self.criteriaArray.append(venue)
                        
                    }
                    
                }
                
            }
            
            print(self.criteriaArray)
            
            self.tableArray = criteriaArray.sorted { Float($0[5]!) < Float($1[5]!) }
            
            self.listTableView.reloadData()
            
        }
    }
    
    // already commented out
    /*func itemsDownloaded(items: NSArray) {
        
        feedItems = items
        self.listTableView.reloadData()
    }*/
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        /*self.filteredArray = searchArray.filter({(names: String) -> Bool in
            return names.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })*/
        
        self.filteredArray = tableArray.filter { (dataArray:[String?]) -> Bool in
            return dataArray.filter({ (string) -> Bool in
                return string!.lowercased().range(of: searchText.lowercased()) != nil
            }).count > 0
        }
        
        if searchText != "" {
            shouldShowSearchResults = true
        } else {
            shouldShowSearchResults = false
        }
        self.listTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of feed items
        
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return tableArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve cell
        let myCell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")! as! CustomVenueCell
        
        /*let item: LocationModel = feedItems[indexPath.row] as! LocationModel
        let pinLocation = CLLocation(latitude: Double(item.latitude!)!, longitude: Double(item.longitude!)!)
        currentLocation = locationManager.location
        let distFromPin: Double = currentLocation.distanceFromLocation(pinLocation)/1000
        _ = item.name
        _ = "\(String(format:"%.1f",distFromPin)) km"
        _ = item.address
        _ = item.city*/
        
        if shouldShowSearchResults {
            let row = (indexPath as NSIndexPath).row
            myCell.venueLabel.text = filteredArray[row][0]
            myCell.distanceLabel.text = filteredArray[row][5]! + " km"
            myCell.addressLabel.text = filteredArray[row][1]
            myCell.cityLabel.text = filteredArray[row][2]
            return myCell
        } else {
            let row = (indexPath as NSIndexPath).row
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        shouldShowSearchResults = true
        self.listTableView.reloadData()
    }
    
    @IBAction func logAction(_ sender: UIButton) {
        let index = sender.tag
        if shouldShowSearchResults {
            routeLatitude = Double(filteredArray[index][3]!)!
            routeLongitude = Double(filteredArray[index][4]!)!
        } else {
            routeLatitude = Double(tableArray[index][3]!)!
            routeLongitude = Double(tableArray[index][4]!)!
        }
        
        self.performSegue(withIdentifier: "myUnwindSegue", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myUnwindSegue" {
            let destViewController : MapViewController = segue.destination as! MapViewController
            
            destViewController.routeLat = routeLatitude
            destViewController.routeLong = routeLongitude
            
            destViewController.makeRoute(routeLatitude,longitude: routeLongitude)
            
        }
        
        if segue.identifier == "LocationChosen" {
            let destViewController : LocationViewController = segue.destination as! LocationViewController
            
            destViewController.venueInfo = self.segueArray
            
        }
        
        if segue.identifier == "FilterPopover" {
            
            let vc : FilterViewController = segue.destination as! FilterViewController
            
            vc.preferredContentSize = CGSize(width: 300, height: 360)
            
            let controller = vc.popoverPresentationController
            
            controller?.sourceView = self.view
            
            controller?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            
            controller?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            if controller != nil {
                controller?.delegate = self
            }
            
            vc.categoryArray = self.categoryArray
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if shouldShowSearchResults {
            self.segueArray = filteredArray[indexPath.row]
        } else {
            self.segueArray = tableArray[indexPath.row]
        }
        
        self.performSegue(withIdentifier: "LocationChosen", sender: self)
        
    }
    
    
    @IBAction func filterButtonTapped(_ sender: AnyObject) {
        
        self.searchBar.text = ""
        
        self.shouldShowSearchResults = false
        
        self.performSegue(withIdentifier: "FilterPopover", sender: self)
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

