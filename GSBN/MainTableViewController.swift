//
//  MainTableViewController.swift
//  GSBN
//
//  Created by User on 2018. 6. 16..
//  Copyright © 2018년 Lazy Ren. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

var infoList : [printInfo] = []
var calcuatedETA: Double = 0.0
struct printInfo {
    var curLine:String
    var information:String
    var curStation:String
    var befStatoin:String
    var aftStation:String
    var trainStatus:String
    var TrainArrival:String
    var departTime:String
    var isLast: Int
    init() {
        curLine = ""
        information = ""
        curStation = ""
        befStatoin = ""
        aftStation = ""
        trainStatus = ""
        TrainArrival = ""
        departTime = ""
        isLast = 0
    }
}

class stationAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    init(title:String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
var destiAnno: stationAnnotation? = nil

class MainTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    
    @IBOutlet weak var stationName: UILabel!
    var stName : String = ""
    let locationManager = CLLocationManager()
    var nearestStationX: Double = 0.0
    var nearestStationY: Double = 0.0

    override func viewDidLoad() {

        super.viewDidLoad()
        print ("enableLocationServices")
        func enableLocationServices() {
            print ("enableLocationServices")
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
        curLoc = location
        let sourcePlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)

        print("locationManager")
        //        locationManager.stopUpdatingLocation()
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let convert : GeoConverter = GeoConverter()
        var currentPosition : GeographicPoint = GeographicPoint(x: locValue.longitude, y: locValue.latitude)
        if let TmPosition = convert.convert(sourceType: .WGS_84, destinationType: .TM, geoPoint: currentPosition) {
            currentPosition = TmPosition
            print(TmPosition)
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
                var stationPosition : GeographicPoint = GeographicPoint(x: self.nearestStationX, y: self.nearestStationY)
                if let TmPosition = convert.convert(sourceType: .TM, destinationType: .WGS_84, geoPoint: stationPosition) {
                    stationPosition = TmPosition
                }

                // Get destination position
                let destinationCoordinates = CLLocationCoordinate2DMake(stationPosition.y, stationPosition.x)
                let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

                // Create Annotation
                destiAnno = stationAnnotation(title: fetchedStations.stationOrderList[0], subtitle: "Destination", coordinate: destinationCoordinates)
                NotificationCenter.default.post(name: NSNotification.Name("annotationNotification"), object: nil)
                
                // Create request
                let request = MKDirectionsRequest()
                request.source = sourceMapItem
                request.destination = destinationMapItem
                request.transportType = MKDirectionsTransportType.walking
                request.requestsAlternateRoutes = false
                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    if let route = response?.routes.first {
                        print("Distance: \(route.distance), ETA: \(route.expectedTravelTime)")
                        calcuatedETA = route.expectedTravelTime - 300
                    } else {
                        print("Error!")
                    }
                    let curArrivalInfo = realtimeSubwayArrivalInfo.init(stationName: fetchedStations.stationOrderList[0], lineInfoList: stationInfo)
                    curArrivalInfo.getArrivalInfo(completionHandler: { (fetchedArrivalInfo) in
                        fetchedArrivalInfo.keys.map({ (line) -> Void in
                            fetchedArrivalInfo[line]?.keys.map({ (updownFlag) -> Void in
                                var passed = false
                                if let entrys = fetchedArrivalInfo[line]?[updownFlag] {
                                    entrys.map({ (entry) -> Void in
                                        //print(line, entry.stationName, entry.directionInfo, entry.curStationName, entry.leftTimeMsg, String(entry.leftTime) + "초 후 도착")
                                        print(entry)
                                        var inserted: Bool = false
                                        for item in infoList {
                                            if (entry.directionInfo == item.trainStatus) {
                                                inserted = true
                                                break
                                            }
                                        }
                                        if (!inserted) {
                                            //                                        print(line)
                                            //                                        print(calcuatedETA)
                                            //                                        print(entry.curStationName)
                                            //                                        print(entry.directionInfo)
                                            //                                        print(entry.arrivalMsg)
                                            //                                        print(Double(entry.leftTime) - calcuatedETA)
                                            var tmp : printInfo = printInfo.init()
                                            var sidestations = getSideStation(stationName: entry.stationName, lineName: line, updownFlag: entry.updownFlag)
                                            if (entry.lastFlag == 1) {
                                                tmp.isLast = 1
                                            }
                                            self.stName = entry.stationName
                                            tmp.curLine = line
                                            tmp.information = entry.stationName
                                            tmp.curStation = entry.stationName
                                            tmp.befStatoin = sidestations[0]
                                            tmp.aftStation = sidestations[1]
                                            tmp.trainStatus = entry.directionInfo
                                            tmp.TrainArrival = entry.arrivalMsg + " 열차 도착 예정"
                                            let msgtmp = Int(entry.arrivalMsg[..<entry.arrivalMsg.index(entry.arrivalMsg.startIndex, offsetBy: 1)])
                                            if msgtmp == nil {
                                                tmp.TrainArrival = entry.arrivalMsg
                                            }
                                            else {
                                                tmp.TrainArrival = entry.arrivalMsg + " 열차 도착 예정"
                                            }
                                            let t = entry.leftTime - Int(calcuatedETA)
                                            print("t: \(t)")
                                            if (t >= 60) {
                                                tmp.departTime = "\(t/60) 분 \(t%60)초 후 출발하세요"
                                            }
                                            else {
                                                tmp.departTime = "\(t%60)초 후 출발하세요"
                                            }
                                            if (t > 0 || passed) {
                                                passed = false
                                                if (t <= 0) {
                                                    tmp.departTime = "지금 출발하세요"
                                                }
                                                infoList.append(tmp)
                                                print(tmp)
                                                DispatchQueue.main.async(execute: {() -> Void in
                                                    print("Reloading tableView")
                                                    self.stationName.text = self.stName
                                                    self.tableView?.reloadData();
                                                })
                                            }
                                            else {
                                                passed = true
                                            }
                                        }
                                        
                                    })
                                }
                            })
                        })
                    })
                }
                
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("infolist count \(infoList.count)")
        return infoList.count
    }



    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! MainTableViewCell
        let tmp : printInfo = infoList[indexPath.row]
//        cell.CurrentLineLbl.text = "6"
//        cell.DepartTimeLbl.text = "6분 뒤 열차 도착"
//        cell.InformationLbl.text = "6호선 합정역 월드컵경기장 방면"
//        cell.NextStationLbl.text = "디지털미디어시티"
//        cell.CurrentStationLbl.text = "월드컵경기장"
//        cell.BeforeStationLbl.text = "마포구청"
//        cell.TrainStatusLbl.text = "마포구청역 출발"
        
        cell.CurrentLineLbl.text = tmp.curLine.substring(to: tmp.curLine.index(after: tmp.curLine.startIndex))
        cell.InformationLbl.text = tmp.information
        cell.DepartTimeLbl.text = tmp.departTime
        cell.TrainArrivalTimeLbl.text = tmp.TrainArrival
        cell.NextStationLbl.text = tmp.aftStation
        cell.CurrentStationLbl.text = tmp.curStation
        cell.BeforeStationLbl.text = tmp.befStatoin
        cell.TrainStatusLbl.text = tmp.trainStatus
        if tmp.isLast == 1 {
            cell.lastTrainLbl.isHidden = false
        }
        else {
            cell.lastTrainLbl.isHidden = true
        }
        
        var Line: String = ""
        switch tmp.curLine {
        case "경의중앙선":
            Line = "K"
        case "경춘선":
            Line = "G"
        case "공항철도":
            Line = "A"
        case "분당선":
            Line = "B"
        case "신분당선":
            Line = "S"
        case "인천1호선":
            Line = "I"
        case "수인선":
            Line = "SU"
        default:
            Line = tmp.curLine.substring(to: tmp.curLine.index(after: tmp.curLine.startIndex))
        }
        
        let templateImage = cell.LineImage.image?.withRenderingMode(.alwaysTemplate)
        cell.LineImage.image=templateImage
        switch Line {
        case "1":
            cell.LineImage.tintColor=UIColor(red: CGFloat(40.0/255.0), green: CGFloat(63.0/255.0), blue: CGFloat(148.0/255.0), alpha: CGFloat(1.0))
        case "2":
            cell.LineImage.tintColor=UIColor(red: CGFloat(65.0/255.0), green: CGFloat(175.0/255.0), blue: CGFloat(78.0/255.0), alpha: CGFloat(1.0))
        case "3":
            cell.LineImage.tintColor=UIColor(red: CGFloat(253.0/255.0), green: CGFloat(115.0/255.0), blue: CGFloat(34.0/255.0), alpha: CGFloat(1.0))
        case "4":
            cell.LineImage.tintColor=UIColor(red: CGFloat(52.0/255.0), green: CGFloat(159.0/255.0), blue: CGFloat(219.0/255.0), alpha: CGFloat(1.0))
        case "5":
            cell.LineImage.tintColor=UIColor(red: CGFloat(136.0/255.0), green: CGFloat(63.0/255.0), blue: CGFloat(221.0/255.0), alpha: CGFloat(1.0))
        case "6":
            cell.LineImage.tintColor=UIColor(red: CGFloat(179.0/255.0), green: CGFloat(80.0/255.0), blue: CGFloat(26.0/255.0), alpha: CGFloat(1.0))
        case "7":
            cell.LineImage.tintColor=UIColor(red: CGFloat(105.0/255.0), green: CGFloat(113.0/255.0), blue: CGFloat(31.0/255.0), alpha: CGFloat(1.0))

        case "8":
            cell.LineImage.tintColor=UIColor(red: CGFloat(224.0/255.0), green: CGFloat(37.0/255.0), blue: CGFloat(110.0/255.0), alpha: CGFloat(1.0))
        case "9":
            cell.LineImage.tintColor=UIColor(red: CGFloat(205.0/255.0), green: CGFloat(163.0/255.0), blue: CGFloat(68.0/255.0), alpha: CGFloat(1.0))
        case "K":
            cell.LineImage.tintColor=UIColor(red: CGFloat(142.0/255.0), green: CGFloat(202.0/255.0), blue: CGFloat(176.0/255.0), alpha: CGFloat(1.0))
        case "G":
            cell.LineImage.tintColor=UIColor(red: CGFloat(30.0/255.0), green: CGFloat(174.0/255.0), blue: CGFloat(124.0/255.0), alpha: CGFloat(1.0))
        case "A":
              cell.LineImage.tintColor=UIColor(red: CGFloat(118.0/255.0), green: CGFloat(183.0/255.0), blue: CGFloat(226.0/255.0), alpha: CGFloat(1.0))
        case "B":
              cell.LineImage.tintColor=UIColor(red: CGFloat(254.0/255.0), green: CGFloat(205.0/255.0), blue: CGFloat(69.0/255.0), alpha: CGFloat(1.0))
        case "S":
            cell.LineImage.tintColor=UIColor(red: CGFloat(165.0/255.0), green: CGFloat(32.0/255.0), blue: CGFloat(52.0/255.0), alpha: CGFloat(1.0))
        case "I":
             cell.LineImage.tintColor=UIColor(red: CGFloat(113.0/255.0), green: CGFloat(154.0/255.0), blue: CGFloat(206.0/255.0), alpha: CGFloat(1.0))
        case "SU":
            cell.LineImage.tintColor=UIColor(red: CGFloat(252.0/255.0), green: CGFloat(203.0/255.0), blue: CGFloat(68.0/255.0), alpha: CGFloat(1.0))
        default : cell.LineImage.tintColor=UIColor(red: CGFloat(252.0/255.0), green: CGFloat(203.0/255.0), blue: CGFloat(68.0/255.0), alpha: CGFloat(1.0))
        }

        return cell

    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
