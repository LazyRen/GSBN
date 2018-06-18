//
//  MainTableViewCell.swiUICurrentStationLabelft
//  GSBN
//
//  Created by User on 2018. 6. 16..
//  Copyright © 2018년 Lazy Ren. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var CurrentLineLbl: UILabel!
    @IBOutlet weak var NextStationLbl: UILabel!
    @IBOutlet weak var CurrentStationLbl: UILabel!
    @IBOutlet weak var TrainArrivalTimeLbl: UILabel!
    @IBOutlet weak var BeforeStationLbl: UILabel!
    @IBOutlet weak var DepartTimeLbl: UILabel!
    @IBOutlet weak var TrainStatusLbl: UILabel!
    @IBOutlet weak var InformationLbl: UILabel!
    @IBOutlet weak var LineImage : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
