//
//  ViewController.swift
//  GSBN
//
//  Created by Lazy Ren on 10/05/2018.
//  Copyright © 2018 Lazy Ren. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var myMapKitView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapKitView.delegate = self
        myMapKitView.showsPointsOfInterest = true
        myMapKitView.showsUserLocation = true
        
        func enableLocationServices() {
            locationManager.delegate = self
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break;
            default:
                break;
            }
        }
        enableLocationServices()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func locationManager(_ _manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        myMapKitView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

