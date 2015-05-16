//
//  PickyFiltersExpandableCell.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/15/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

class PickyFiltersExpandableCell: UITableViewCell {
    
    @IBOutlet var filterNameLabel: UILabel!
    
    @IBOutlet var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
