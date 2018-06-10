//
//  TrainTableViewCell.swift
//  GSBN
//
//  Created by Lazy Ren on 10/05/2018.
//  Copyright © 2018 Lazy Ren. All rights reserved.
//

import UIKit

class TrainTableViewCell: UITableViewCell {

    @IBOutlet weak var trainName: UILabel!
    @IBOutlet weak var trainArrival: UILabel!
    @IBOutlet weak var trainIcon: UIImageView!
    
    var trainCell: Train? {
        didSet {
            if let curCell = trainCell {
                self.trainName.text = curCell.name
                self.trainArrival.text = curCell.estimatedArrival
//                self.trainIcon.image = UIImage(named:curCell.image)
            }
            else {
                self.trainName.text = ""
                self.trainArrival.text = ""
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
