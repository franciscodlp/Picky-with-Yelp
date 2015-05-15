//
//  PickyFilterBasicCell.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/14/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

@objc protocol PickyFiltersCategoryCellDelegate {
    optional func pickyFiltersCategoryCell(pickyFiltersCategoryCell: PickyFiltersCategoryCell, didChangeValue value: Bool)
    
}

class PickyFiltersCategoryCell: UITableViewCell {

    @IBOutlet var filterNameLabel: UILabel!
    
    @IBOutlet var onFilterSwitch: UISwitch!
    
    weak var delegate: PickyFiltersCategoryCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        onFilterSwitch.addTarget(self, action: "switchValueChanged", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    var category: [String:String]! {
        didSet{
            filterNameLabel.text = category["title"]
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func switchValueChanged() {
        delegate?.pickyFiltersCategoryCell?(self, didChangeValue: onFilterSwitch.on)
    }

}
