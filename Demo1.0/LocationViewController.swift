//
//  LocationViewController.swift
//  Demo1.0
//
//  Created by User on 2016-10-30.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var machineLocation: UILabel!
    @IBOutlet weak var getDirections: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation! = nil
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    var currentCoordinates = CLLocationCoordinate2D()
    var currentLocation : CLLocation! = nil
    var venueInfo = [String?]()
    var myLat = Double()
    var myLong = Double()
    
    override func viewDidLoad() {
        locationManager.delegate = self
        self.mapView.delegate = self
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsCompass = false
        self.mapView.isRotateEnabled = false
        print("Venue info is: \(self.venueInfo)")
        self.venueLabel.text = venueInfo[0]
        self.distanceLabel.text = venueInfo[5]! + " km"
        self.addressLabel.text = venueInfo[1]
        self.cityLabel.text = venueInfo[2]
        self.machineLocation.text = venueInfo[7]
        
        getDirections.layer.cornerRadius = 15
        
        machineLocation.lineBreakMode = .byWordWrapping
        machineLocation.numberOfLines = 0
        
        let latitude = venueInfo[3]
        let longitude = venueInfo[4]
        
        let lttude = Double(latitude!)
        let lgtude = Double(longitude!)
        let poiCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lttude!, longitude: lgtude!)
        
        let category = venueInfo[6]
        
        self.pointAnnotation = CustomPointAnnotation()
        if category == "Bar" {
            self.pointAnnotation.pinCustomImageName = "Beer.png"
        } else if category == "Restaurant"{
            self.pointAnnotation.pinCustomImageName = "Restaurant.png"
        } else if category == "Cafe" {
            self.pointAnnotation.pinCustomImageName = "Cafe.png"
        } else if category == "Hotel" {
            self.pointAnnotation.pinCustomImageName = "Office.png"
        } else if category == "Casino" {
            self.pointAnnotation.pinCustomImageName = "Casino.png"
        } else {
            self.pointAnnotation.pinCustomImageName = "Transit.png"
        }
        self.pointAnnotation.coordinate = poiCoordinates
        
        let pinLocation = CLLocation(latitude: lttude!, longitude: lgtude!)
        
        self.pointAnnotation.distanceToVenue = "\(venueInfo[5]) km"
        self.pointAnnotation.name = venueInfo[0]
        self.pointAnnotation.address = venueInfo[1]
        
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: "pin")
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        
        let center = CLLocationCoordinate2D(latitude: lttude!, longitude: lgtude!)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)
        
        startSignificantChangeUpdates()
        
    }

    @IBAction func backButtonTapped(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "unwindToVenues", sender: self)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        
        let pinImage = UIImage(named: customPointAnnotation.pinCustomImageName)
        
        annotationView?.image = pinImage
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        
        if view.annotation is MKUserLocation {
            return
        }
        
        let customAnnotation = view.annotation as! CustomPointAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.venueName.text = customAnnotation.name
        calloutView.addressOfVenue.text = customAnnotation.address
        calloutView.distanceToVenue.text = customAnnotation.distanceToVenue
        
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    func startSignificantChangeUpdates () {
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = kCLDistanceFilterNone
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.lastLocation = manager.location
        
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        currentCoordinates = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        self.myLat = location!.coordinate.latitude
        self.myLong = location!.coordinate.longitude
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    @IBAction func getDirectionsTapped(_ sender: AnyObject) {
        
        let directionsURL = "http://maps.apple.com/?saddr=\(self.myLat),\(self.myLong)&daddr=\(venueInfo[3]!),\(venueInfo[4]!)"
        
        print(directionsURL)
        
        if let url = NSURL(string: directionsURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
            else
            {
                UIApplication.shared.openURL(url as URL)
            }
        }
        
    }
    
}
