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

<<<<<<< HEAD
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager = CLLocationManager()
    var nearestStationX: Double = 0.0
    var nearestStationY: Double = 0.0
    let Train = ["동대문역사문화공원", "왕십리", "상왕십리"]

    @IBOutlet weak var tableView: UITableView!
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
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! MainTableViewCell

        cell.CurrentLineLbl.text = "6"
        cell.CurrentStationLbl.text = "동대문역사문화공원"
        cell.DepartTimeLbl.text = "6분 뒤 열차 도착"
        cell.InformationLbl.text = "6호선 합정역 월드컵경기장 방면"
        cell.NextStationLbl.text = "디지털미디어시티"
        cell.CurrentStationLbl.text = "월드컵경기장"
        cell.BeforeStationLbl.text = "마포구청"
        cell.TrainStatusLbl.text = "마포구청역 출발"

        return cell
    }
}
