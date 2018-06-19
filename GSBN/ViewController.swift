//
//  ViewController.swift
//  GSBN
//
//  Created by Lazy Ren on 19/06/2018.
//  Copyright © 2018 Lazy Ren. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var MyMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        MyMapView.delegate = self
        MyMapView.showsPointsOfInterest = true
        MyMapView.showsUserLocation = true
        // Do any additional setup after loading the view.
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get current position
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
//        let sourcePlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        MyMapView.setRegion(coordinateRegion, animated: true)
        if let anno = destiAnno {
            MyMapView.addAnnotation(anno)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
