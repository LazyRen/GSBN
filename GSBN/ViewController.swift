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

func getNearestStations (fetchLoc:GeographicPoint?, completionHandler: @escaping (_ fetchedData : [[String:Any]]) -> Void) -> Void {
    let apistr = "http://swopenAPI.seoul.go.kr/api/subway/6e574a4d58636b6436357942596163/json/nearBy/0/5/"
    if let locVal = fetchLoc {
        guard let encodedUrl = (apistr + String(locVal.x) + "/" + String(locVal.y)).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else {
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
    var nearestStationX: Double = 0.0
    var nearestStationY: Double = 0.0
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
//        if let path = Bundle.main.path(forResource: "stations", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
//                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let stations = jsonResult["station"] as? [Any] {
//                    print("JSON parse succeed")
//                }
//            } catch {
//                print("failed to parse json file")
//            }
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get current position
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        let sourcePlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        myMapKitView.setRegion(coordinateRegion, animated: true)
        
//        locationManager.stopUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        resultLabel.text = "lat = \(locValue.latitude)"
        resultLabel2.text = "lon = \(locValue.longitude)"
        let convert : GeoConverter = GeoConverter()
        var currentPosition : GeographicPoint = GeographicPoint(x: locValue.longitude, y: locValue.latitude)
        if let TmPosition = convert.convert(sourceType: .WGS_84, destinationType: .TM, geoPoint: currentPosition) {
            currentPosition = TmPosition
//            print(TmPosition)
        }
        else {
            print("failed to convert")
        }
        
        print("position converted: \(currentPosition)")
        let nearestStation = RealtimeSubwayNearestStations.init(WGS_N: locValue.longitude, WGS_E: locValue.latitude)
        nearestStation.getNearestStations { (fetchedStations) in
            if let stationInfo = fetchedStations.stationList[nearestStation.stationInfo.stationOrderList[0]] {
                self.nearestStationX = stationInfo[0].stationX
                self.nearestStationY = stationInfo[0].stationY
                let curArrivalInfo = realtimeSubwayArrivalInfo.init(stationName: fetchedStations.stationOrderList[1], lineInfoList: stationInfo)
                curArrivalInfo.getArrivalInfo(completionHandler: { (fetchedArrivalInfo) in
                    fetchedArrivalInfo.keys.map({ (line) -> Void in
                        fetchedArrivalInfo[line]?.keys.map({ (updownFlag) -> Void in
                            if let entrys = fetchedArrivalInfo[line]?[updownFlag] {
                                entrys.map({ (entry) -> Void in
                                    //print(line, entry.stationName, entry.directionInfo, entry.curStationName, entry.leftTimeMsg, String(entry.leftTime) + "초 후 도착")
                                    print(entry)
                                })
                            }
                        })
                    })
                })
                var stationPosition : GeographicPoint = GeographicPoint(x: self.nearestStationX, y: self.nearestStationY)
                if let TmPosition = convert.convert(sourceType: .TM, destinationType: .WGS_84, geoPoint: stationPosition) {
                    stationPosition = TmPosition
                    //                print(TmPosition)
                }
                
                // Get destination position
                let destinationCoordinates = CLLocationCoordinate2DMake(stationPosition.y, stationPosition.x)
                let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                
                // Create request
                let request = MKDirectionsRequest()
                request.source = sourceMapItem
                request.destination = destinationMapItem
                request.transportType = MKDirectionsTransportType.walking
                request.requestsAlternateRoutes = false
                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    if let route = response?.routes.first {
                        //                    print(location)
                        //                    print(destinationCoordinates)
                        print("Distance: \(route.distance), ETA: \(route.expectedTravelTime)")
                    } else {
                        print("Error!")
                    }
                }
            }
        }
//        getNearestStations(fetchLoc: currentPosition) { fetchedData in
//            print(fetchedData)
//            if let tmp = fetchedData[0]["subwayXcnts"] as? String {
//                if let x = Double(tmp) {
//                    self.nearestStationX = Double(x)
//                }
//
//            }
//            if let tmp = fetchedData[0]["subwayYcnts"] as? String {
//                if let y = Double(tmp) {
//                    self.nearestStationY = Double(y)
//                }
//            }
////            print(fetchedData[0]["statnNm"])
////            print("\n")
////            print("\(self.nearestStationX), \(self.nearestStationY)")
////            print("\n")
//
//            var stationPosition : GeographicPoint = GeographicPoint(x: self.nearestStationX, y: self.nearestStationY)
//            if let TmPosition = convert.convert(sourceType: .TM, destinationType: .WGS_84, geoPoint: stationPosition) {
//                stationPosition = TmPosition
////                print(TmPosition)
//            }
//            
//            // Get destination position
//            let destinationCoordinates = CLLocationCoordinate2DMake(stationPosition.y, stationPosition.x)
//            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
//            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//
//            // Create request
//            let request = MKDirectionsRequest()
//            request.source = sourceMapItem
//            request.destination = destinationMapItem
//            request.transportType = MKDirectionsTransportType.walking
//            request.requestsAlternateRoutes = false
//            let directions = MKDirections(request: request)
//            directions.calculate { response, error in
//                if let route = response?.routes.first {
////                    print(location)
////                    print(destinationCoordinates)
//                    print("Distance: \(route.distance), ETA: \(route.expectedTravelTime)")
//                } else {
//                    print("Error!")
//                }
//            }
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
