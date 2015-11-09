//
//  ExhibitsTableViewCell.swift
//  MuseumApp
//
//  Created by James Payne on 11/6/15.
//  Copyright © 2015 James Payne. All rights reserved.
//

import UIKit

class ExhibitsTableViewCell: UITableViewCell {

    var segueID = "toExhibitTextController"
    
    @IBOutlet weak var exhibitNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
