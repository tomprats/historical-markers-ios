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
    @IBOutlet weak var nearbyButton: UIButton!
    @IBAction func nearbyButtonClick(_ sender: AnyObject) {
        UIApplication.shared.open(nearbyURL, options: [:], completionHandler: nil)
    }
    
    var nearbyURL: URL!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nearbyButton.isHidden = true
    }
    
    func viewDidAppear() {
        checkLocationAuthorization()
    }
    
    func locationManager(_ locationManager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            showLocationButton(latitude: String(latitude), longitude: String(longitude))
        } else {
            showLocationError(error: "There was a problem finding your location. Please try again later.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showLocationError(error: error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            let alertController = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to use this app, please open this app's settings and update the location access.",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                let url = URL(string:UIApplicationOpenSettingsURLString)
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func showLocationButton(latitude: String, longitude: String) {
        nearbyURL = URL(string: "https://www.hmdb.org/map.asp?nearby=yes&Latitude=\(latitude)&Longitude=\(longitude)")
        nearbyButton.isHidden = false
    }
    
    func showLocationError(error: String) {
        let alertController = UIAlertController(
            title: "Could Not Find Location",
            message: error,
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
