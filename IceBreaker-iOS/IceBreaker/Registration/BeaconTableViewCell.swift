//
//  beaconTableViewCell.swift
//  IceBreaker
//
//  Created by Jacob Chen on 3/10/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import UIKit

class BeaconTableViewCell: UITableViewCell {

    var myBeacon: ESTBeacon?
    
    @IBOutlet var majorIDLabel: UILabel!
    @IBOutlet var minorIDLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setBeacon(aBeacon: ESTBeacon) {
        
        myBeacon = aBeacon
        
        self.majorIDLabel.text = myBeacon?.major.stringValue
        self.minorIDLabel.text = myBeacon?.minor.stringValue
        
    }

}
