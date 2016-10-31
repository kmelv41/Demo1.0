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
        
        let latitude = venueInfo[3]
        let longitude = venueInfo[4]
        
        let lttude = Double(latitude!)
        let lgtude = Double(longitude!)
        let poiCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lttude!, longitude: lgtude!)
        
        let category = venueInfo[6]
        
        self.pointAnnotation = CustomPointAnnotation()
        if category == "Bar" {
            self.pointAnnotation.pinCustomImageName = "Beer_Closed.png"
        } else if category == "Restaurant"{
            self.pointAnnotation.pinCustomImageName = "Restaurant.png"
        } else if category == "Cafe" {
            self.pointAnnotation.pinCustomImageName = "Cafe.png"
        } else if category == "Office" {
            self.pointAnnotation.pinCustomImageName = "Office.png"
        } else if category == "Casino" {
            self.pointAnnotation.pinCustomImageName = "Casino.png"
        } else {
            self.pointAnnotation.pinCustomImageName = "Transit.png"
        }
        self.pointAnnotation.coordinate = poiCoordinates
        
        let pinLocation = CLLocation(latitude: lttude!, longitude: lgtude!)
        
        self.pointAnnotation.distanceToVenue = "\(venueInfo[6]) km"
        self.pointAnnotation.name = venueInfo[0]
        self.pointAnnotation.address = venueInfo[1]
        
        self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: "pin")
        self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        
        let center = CLLocationCoordinate2D(latitude: lttude!, longitude: lgtude!)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        self.mapView.setRegion(region, animated: true)

        
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
        
        /*let subtitleView = UILabel()
         subtitleView.font = subtitleView.font.fontWithSize(12)
         subtitleView.numberOfLines = 0
         subtitleView.text = "Testing"
         annotationView?.detailCalloutAccessoryView = subtitleView*/
        
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let customAnnotation = view.annotation as! CustomPointAnnotation
        let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
        let calloutView = views?[0] as! CustomCalloutView
        calloutView.venueName.text = customAnnotation.name
        calloutView.addressOfVenue.text = customAnnotation.address
        calloutView.distanceToVenue.text = customAnnotation.distanceToVenue
        
        // 3
        calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height*0.52)
        view.addSubview(calloutView)
        
        
        //mapView.setCenter((view.annotation?.coordinate)!, animated: true)
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
    
}
