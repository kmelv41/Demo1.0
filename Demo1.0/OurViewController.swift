//
//  OurViewController.swift
//  Demo1.0
//
//  Created by User on 2016-08-12.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class OurViewController: UIViewController, CLLocationManagerDelegate, NSURLSessionDataDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation! = nil
    @IBOutlet weak var venueButton: UIBarButtonItem!
    var feedItems: NSArray = NSArray()
    var data : NSMutableData = NSMutableData()
    let urlPath: String = "http://joltmobiledemo.com/service.php"
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        }
        locationManager.delegate = self
        mapView.delegate = self
        startSignificantChangeUpdates()
        downloadItems()
        mapView.showsPointsOfInterest = false
        mapView.showsCompass = false
        mapView.rotateEnabled = false
    }
    
    @IBAction func myUnwindAction(sender: UIStoryboardSegue) {
        // nothing yet
    }
    

    // MARK: CLLocationManagerDelegateProtocol
    func startSignificantChangeUpdates () {
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            self.locationManager.requestAlwaysAuthorization()
        }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = manager.location
        
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // need to add error coding
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        
        let pinImage = UIImage(named: customPointAnnotation.pinCustomImageName)
        
        annotationView?.image = pinImage
        
        return annotationView
    }
    
    func downloadItems() {
        
        let url: NSURL = NSURL(string: urlPath)!
        var session: NSURLSession!
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTaskWithURL(url)
        
        task.resume()
        
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            self.parseJSON()
        }
    }
    
    func parseJSON() {
        
        var jsonResult: NSMutableArray = NSMutableArray()
        
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        var jsonElement: NSDictionary = NSDictionary()
        let locations: NSMutableArray = NSMutableArray()
        
        for i in 0..<jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let location = LocationModel()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let name = jsonElement["Name"] as? String,
                let address = jsonElement["Address"] as? String,
                let latitude = jsonElement["Latitude"] as? String,
                let longitude = jsonElement["Longitude"] as? String,
                let category = jsonElement["Category"] as? String
            {
                
                location.name = name
                location.address = address
                location.latitude = latitude
                location.longitude = longitude
                location.category = category
                
                let lttude = Double(latitude)
                let lgtude = Double(longitude)
                let poiCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lttude!, longitude: lgtude!)
                
                // MARK - adding Pin annotations, need to change this to images
                // this part is current looping through each record in the data pull and adding an annotation to each one

                pointAnnotation = CustomPointAnnotation()
                if category == "Bar" {
                    pointAnnotation.pinCustomImageName = "Beer.png"
                } else if category == "Restaurant"{
                    pointAnnotation.pinCustomImageName = "Restaurant.png"
                } else if category == "Cafe" {
                    pointAnnotation.pinCustomImageName = "Cafe.png"
                } else {
                    pointAnnotation.pinCustomImageName = "Office.png"
                }
                pointAnnotation.coordinate = poiCoordinates
                pointAnnotation.title = name
                
                pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
                mapView.addAnnotation(pinAnnotationView.annotation!)
                
                }
            }
            
            locations.addObject(LocationModel)
        
        }
    
    
    }
    
    
    // MARK - Data pull for tableview
    /*
     override func viewDidLoad() {
     super.viewDidLoad()
     
     //set delegates and initialize homeModel
     
     self.listTableView.delegate = self
     self.listTableView.dataSource = self
     
     let homeModel = HomeModel()
     homeModel.delegate = self
     homeModel.downloadItems()
     
     }
     
     func itemsDownloaded(items: NSArray) {
     
     feedItems = items
     self.listTableView.reloadData()
     }
     
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // Return the number of feed items
     return feedItems.count
     
     }
     
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     // Retrieve cell
     let cellIdentifier: String = "BasicCell"
     let myCell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
     // Get the location to be shown
     let item: LocationModel = feedItems[indexPath.row] as! LocationModel
     // Get references to labels of cell
     myCell.textLabel!.text = item.name! + " - " + item.address!
     
     return myCell
     }
 */
    
    // MARK - mapView from tutorial
    
/*
    
    override func viewDidAppear(animated: Bool) {
        // Create coordinates from location lat/long
        var poiCoodinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        poiCoodinates.latitude = CDouble(self.selectedLocation!.latitude!)!
        poiCoodinates.longitude = CDouble(self.selectedLocation!.longitude!)!
        // Zoom to region
        let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(poiCoodinates, 750, 750)
        self.mapView.setRegion(viewRegion, animated: true)
        // Plot pin
        let pin: MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = poiCoodinates
        self.mapView.addAnnotation(pin)
        
        //add title to the pin
        pin.title = selectedLocation!.name
    }
 
 */
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
