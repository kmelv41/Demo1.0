//
//  CustomVenueCell.swift
//  Demo1.0
//
//  Created by User on 2016-09-02.
//  Copyright © 2016 Jolt. All rights reserved.
//

import UIKit

class CustomVenueCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
