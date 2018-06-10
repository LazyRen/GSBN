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

struct station: Decodable{
    var line_num: Int
    var cyber_st_code: String
    var xpoint_wgs: Double
    var ypoint: Int
    var ypoint_wgs: Double
    var xpoint: Int
    var station_cd: String
    var station_nm: String
    var fr_code: String
}

func getNearestStations (fetchLoc:CLLocationCoordinate2D?, completionHandler: @escaping (_ fetchedData : [[String:Any]]) -> Void) -> Void {
    let apistr = "http://swopenAPI.seoul.go.kr/api/subway/6e574a4d58636b6436357942596163/json/nearBy/0/5/"
    if let locVal = fetchLoc {
        guard let encodedUrl = (apistr + String(locVal.latitude) + "/" + String(locVal.longitude)).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else {
            print("failed to encode URL")
            return
        }
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print("HTTP Error")
                print(err)
            }
            else {
                if let usableData = data {
                    do {
                        //parse responed JSON data
                        let jsonSerialized = try JSONSerialization.jsonObject(with: usableData, options: []) as? [String : Any]
                        
                        guard let json = jsonSerialized else {
                            print("parsed JSON referring error")
                            return
                        }
                        
                        guard let fetchedStationList = json["stationList"] as? [[String:Any]] else {
                            print("parsed JSON referring error")
                            return
                        }
                        completionHandler(fetchedStationList)
                        
                    } catch let error as NSError {
                        print("JSON parsing error.")
                        print(error.localizedDescription)
                        
                        //api 서버가 죽는 경우가 많아서 에러가 났을 때 HTTP 코드를 볼 수 있도록 하는 코드 추가
                        if let httpResponse = response as? HTTPURLResponse {
                            print(httpResponse.statusCode)
                        }
                        
                    }
                }
                
            }
        }
        task.resume()
    }
    else {
        print("failed to get locVal")
        return
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var myMapKitView: MKMapView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultLabel2: UILabel!
    @IBOutlet weak var testLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapKitView.delegate = self
        myMapKitView.showsPointsOfInterest = true
        myMapKitView.showsUserLocation = true
        
        func enableLocationServices() {
            locationManager.delegate = self
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                break;
            default:
                break;
            }
        }
        enableLocationServices()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        if let path = Bundle.main.path(forResource: "stations", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let stations = jsonResult["station"] as? [Any] {
                    print("parse json succeed")
                }
            } catch {
                print("failed to parse json file")
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        myMapKitView.setRegion(coordinateRegion, animated: true)
//        locationManager.stopUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        resultLabel.text = "lat = \(locValue.latitude)"
        resultLabel2.text = "lon = \(locValue.longitude)"
        getNearestStations(fetchLoc: locValue) { fetchedData in
            print(fetchedData[0])
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
