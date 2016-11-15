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
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import GoogleSignIn

class MapViewController: UIViewController, CLLocationManagerDelegate, URLSessionDataDelegate, MKMapViewDelegate, GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation! = nil
    @IBOutlet weak var venueButton: UIBarButtonItem!
    var pointAnnotation:CustomPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    let rootRef = FIRDatabase.database().reference()
    var routeLat = Double()
    var routeLong = Double()
    var currentCoordinates = CLLocationCoordinate2D()
    var currentLocation : CLLocation! = nil
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var authProvider = String()
    var uid = String()
    var subscriptionStatus = 0
    
    
    override func viewDidLoad() {
        getData()
        self.memberButton.isHidden = true
        self.mapView.isUserInteractionEnabled = true
        locationManager.delegate = self
        self.mapView.delegate = self
        locationManager.requestAlwaysAuthorization()
        startSignificantChangeUpdates()
        // downloadItems()
        self.mapView.showsPointsOfInterest = false
        self.mapView.showsCompass = false
        self.mapView.isRotateEnabled = false
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        self.emailButton.layer.cornerRadius = 3
        self.memberButton.layer.cornerRadius = 15
        
        //self.signInButton.colorScheme = GIDSignInButtonColorScheme.dark
        self.signInButton.style = GIDSignInButtonStyle.wide
        
        self.loginButton.delegate = self
        self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.loginButton.loginBehavior = FBSDKLoginBehavior.browser
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                
                super.viewDidLoad()
                if self.revealViewController() != nil {
                    self.menuButton.target = self.revealViewController()
                    self.menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
                    self.revealViewController().delegate = self
                    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                    self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
                }

                self.loginButton.isHidden = true
                self.signInButton.isHidden = true
                self.emailButton.isHidden = true
                
                self.uid = (FIRAuth.auth()?.currentUser?.uid)!

                self.rootRef.child("Users").child(self.uid).observe(.value, with: { snapshot in
                    
                    FIRAuth.auth()?.addStateDidChangeListener { auth, user in
                        if let user = user {
                            
                            if snapshot.hasChild("Name") {
                                
                                let dataPull = snapshot.value! as! [String:AnyObject]
                                
                                if snapshot.hasChild("Subscription") {
                                    self.subscriptionStatus = (dataPull["Subscription"]! as! Int)
                                }
                                
                                if self.subscriptionStatus == 1 {
                                    self.memberButton.isHidden = true
                                } else {
                                    self.memberButton.isHidden = false
                                }
                                
                            }
                            
                        } else {
                            
                            self.subscriptionStatus = 0
                            self.memberButton.isHidden = true
                            
                        }
                        
                    }
                    
                })
                
            } else {
                // No user is signed in.
                // show user login button.
                
                //self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                //self.view.addSubview(self.loginButton)
                
            }
        }

        
    }
    
    @IBAction func menuButtonTapped(_ sender: AnyObject) {
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                // User is signed in.
                
                //self.mapView.isUserInteractionEnabled = false
                
                // original segue code
                //let mainStoryboard: UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
                //let loggedInViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("loggedInView")
                
                //self.presentViewController(loggedInViewController, animated: true, completion: nil)
                
            } else {
                // No user is signed in.
                // show user login button.
                
                self.showAlertWithOK(header: "Hi There!", message: "Please sign in using one of the options below before navigating to the purchases page.")
                
                
                //self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                //self.view.addSubview(self.loginButton)
                
            }
        }

        
    }
    
    
    @IBAction func memberButtonTapped(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "showPurchases", sender: self)
        
    }
    
    
    @IBAction func loginToEmailTapped(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "presentEmailLogin", sender: self)
        
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        progressBarDisplayer("Logging In", true)
        
        if(error != nil) {
            
            self.hideActivityIndicator()
            
        } else if(result.isCancelled) {
            
            self.hideActivityIndicator()
            
        } else {
            
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                print("User logged into Firebase with Facebook")
                
                let disGroup = DispatchGroup()
                
                disGroup.enter()
                
                let user = FIRAuth.auth()?.currentUser
                
                let name: String = (user?.displayName)! as String
                let email: String = (user?.email)! as String
                self.uid = (user?.uid)! as String
                
                self.authProvider = "Facebook"
                
                self.rootRef.child("Users").child(self.uid).observeSingleEvent(of: .value, with: { snapshot in
                    
                    if self.authProvider == "Facebook" {
                        
                        if snapshot.hasChild(self.uid) {
                            
                            print("User already exists")
                            
                        } else {
                            
                            self.rootRef.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":"","Status":"Active","Subscription":0])
                            
                        }
                        
                    }
                    
                    disGroup.leave()
                    
                })
                
                disGroup.notify(queue: DispatchQueue.main, execute: {
                    
                    self.hideActivityIndicator()
                    
                    self.showAlertWithOK(header: "Login Successful", message: "")
                    
                })
                
            }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        progressBarDisplayer("Logging In", true)
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user,error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            print("User logged in with Google")
            
            let user = FIRAuth.auth()?.currentUser
            
            let name: String = (user?.displayName)! as String
            let email: String = (user?.email)! as String
            self.uid = (user?.uid)! as String
            
            self.authProvider = "Google"
            
            let disGroup = DispatchGroup()
            
            disGroup.enter()
            
            self.rootRef.child("Users").child(self.uid).observeSingleEvent(of: .value, with: { snapshot in
                
                if self.authProvider == "Google" {
                    
                    if snapshot.hasChild(self.uid) {
                        
                        print("User already exists")
                        
                    } else {
                        
                        self.rootRef.child("Users").child(self.uid).setValue(["Name":name,"Email":email,"Phone":"","Status":"Active","Subscription":0])
                        
                    }
                    
                }
                
                disGroup.leave()
                
            })
            
            disGroup.notify(queue: DispatchQueue.main, execute: {
                
                self.hideActivityIndicator()
                
                self.showAlertWithOK(header: "Login Successful", message: "")
                
            })
            
        })
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        try! FIRAuth.auth()!.signOut()
        
    }
    
    @IBAction func myUnwindAction(_ sender: UIStoryboardSegue) {
        // nothing yet
    }
    
    func getData() {
        let venueRef = rootRef.child("venues")
        var dataPull = [[String:String]]()

        venueRef.observe(.value, with: { (snapshot: FIRDataSnapshot!) in
            
            dataPull = snapshot.value! as! [[String:String]]
            
            for i in 0..<dataPull.count
            {
                
                if let name = dataPull[i]["Name"],
                    let latitude = dataPull[i]["Latitude"],
                    let longitude = dataPull[i]["Longitude"],
                    let address = dataPull[i]["Address"],
                    let category = dataPull[i]["Category"] {
                    
                    let lttude = Double(latitude)
                    let lgtude = Double(longitude)
                    let poiCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lttude!, longitude: lgtude!)
                    
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
                    self.currentLocation = self.locationManager.location
                    let distFromPin: Double = self.currentLocation.distance(from: pinLocation)/1000
                    let strFromPin = String(format:"%.1f",distFromPin)
                    
                    self.pointAnnotation.distanceToVenue = "\(strFromPin) km"
                    self.pointAnnotation.name = name
                    self.pointAnnotation.address = address
                    
                    self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: "pin")
                    self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                }
            }
            
        })
        
    }
    
    // MARK: CLLocationManagerDelegateProtocol
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
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    /*func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // need to add error coding
    }*/
    
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
    
    
    /*@IBAction func logoTapped(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Your battery is down to 20%, the closest Wharf station is here:", message: "Union Station, 121 Front St W", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Get Directions", style: .default, handler: nil)
        
        let altAction = UIAlertAction(title: "No Thanks", style: .destructive, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(altAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }*/
    
    func progressBarDisplayer(_ msg:String, _ indicator:Bool ) {
        
        if self.messageFrame.isHidden == true {
            
            print(msg)
            strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
            strLabel.text = msg
            strLabel.textColor = UIColor.white
            messageFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
            messageFrame.layer.cornerRadius = 15
            messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
            if indicator {
                activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
                activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                activityIndicator.startAnimating()
                messageFrame.addSubview(activityIndicator)
            }
            messageFrame.addSubview(strLabel)
            view.addSubview(messageFrame)
            
        }

    }
    
    func showAlertWithOK(header:String, message:String) {
        
        let alertController = UIAlertController(title: header, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func hideActivityIndicator() {
        
        self.activityIndicator.stopAnimating()
        self.strLabel.isHidden = true
        self.messageFrame.isHidden = true
        self.activityIndicator.isHidden = true
        
    }
    
}

    
