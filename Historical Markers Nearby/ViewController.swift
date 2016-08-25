//
//  ViewController.swift
//  Historical Markers Nearby
//
//  Created by Tom Prats on 8/12/16.
//  Copyright © 2016 Tomify. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nearbyButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    @IBAction func nearbyButtonClick(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(nearbyURL)
    }
    
    var nearbyURL: NSURL!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(willEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func didBecomeActive() {
        setState("loading")
    }
    
    func willEnterForeground() {
        checkLocationAuthorization()
    }
    
    func locationManager(locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            nearbyURL = NSURL(string: "https://www.hmdb.org/map.asp?nearby=yes&Latitude=\(latitude)&Longitude=\(longitude)")
            
            self.setState("ready")
        } else {
            showLocationError("There was a problem finding your location. Please try again later.")
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        showLocationError(error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            locationManager.requestLocation()
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            self.setState("Location Access Disabled")
            
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to use this app, please open this app's settings and update the location access.",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:  nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                let url = NSURL(string:UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(url!)
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    func showLocationError(error: String) {
        self.setState(error)
        
        let alertController = UIAlertController(
            title: "Could Not Find Location",
            message: error,
            preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func setState(state: String) {
        switch state {
        case "loading":
            loadingIndicator.startAnimating()
            nearbyButton.hidden = true
            errorMessage.hidden = true
        case "ready":
            loadingIndicator.stopAnimating()
            nearbyButton.hidden = false
            errorMessage.hidden = true
        default:
            loadingIndicator.stopAnimating()
            nearbyButton.hidden = true
            errorMessage.hidden = false
            errorMessage.text = "Location Error: \(state)"
        }
    }
}
