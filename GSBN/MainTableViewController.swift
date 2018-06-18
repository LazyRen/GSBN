//
//  MainTableViewController.swift
//  GSBN
//
//  Created by User on 2018. 6. 16..
//  Copyright © 2018년 Lazy Ren. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! MainTableViewCell
        
        let Line = "3"
        
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
        
       
        
        
        

        
        
       
       
       
        
       
       
        
       
        
        
        
        cell.CurrentLineLbl.text = "6"
        cell.CurrentStationLbl.text = "동대문역사문화공원"
        cell.DepartTimeLbl.text = "6분 뒤 출발하세요~"
        cell.InformationLbl.text = "6호선 합정역 월드컵경기장 방면"
        cell.NextStationLbl.text = "디지털미디어시티"
        cell.CurrentStationLbl.text = "월드컵경기장"
        cell.BeforeStationLbl.text = "마포구청"
        cell.TrainStatusLbl.text = "마포구청역 출발"
        cell.TrainArrivalTimeLbl.text = "6분 뒤 열차 도착"
        
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
