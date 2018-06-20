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

var curLoc : CLLocation = CLLocation.init()

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
   @IBOutlet weak var MyMapView: MKMapView!
    let locationManager = CLLocationManager()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isBeingPresented || isMovingToParentViewController {
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let coordinateRegion = MKCoordinateRegion(center:curLoc.coordinate,span: span)
            MyMapView.setRegion(coordinateRegion, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let annotationNotification = Notification.Name("annotationNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(addMapAnnotation(obj:)), name: annotationNotification, object: nil)
        
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
        curLoc = location
        
//        let coordinateRegion = MKCoordinateRegion(center:location.coordinate,span: span)
//        let sourcePlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
//        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//        MyMapView.setRegion(coordinateRegion, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func addMapAnnotation(obj: Notification) {
        if let tmpAnno = destiAnno {
            MyMapView.addAnnotation(tmpAnno)
            MyMapView.showAnnotations([tmpAnno], animated: true )
        }
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
