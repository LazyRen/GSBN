//
//  ViewController.swift
//  GSBN
//
//  Created by Lazy Ren on 10/05/2018.
//  Copyright © 2018 Lazy Ren. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
   
    let Train = ["동대문역사문화공원", "왕십리", "상왕십리"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

