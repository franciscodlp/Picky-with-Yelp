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
        onFilterSwitch.onImage = UIImage(named: "SwitchbuttonOn")
        onFilterSwitch.offImage = UIImage(named: "SwitchbuttonOff")
        
//        onFilterSwitch.thumbTintColor = UIColor(patternImage: UIImage(named: "SwitchKnobPattern")!)
        onFilterSwitch.tintColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        onFilterSwitch.onTintColor = UIColor(red: (245.0 / 255.0), green: (166.0 / 255.0), blue: (35.0 / 255.0), alpha: 1)
        onFilterSwitch.thumbTintColor = UIColor(red: (90.0 / 255.0), green: (95.0 / 255.0), blue: (85.0 / 255.0), alpha: 1)

        // Configure the view for the selected state
        
    }
    
    
    func switchValueChanged() {
        delegate?.pickyFiltersCategoryCell?(self, didChangeValue: onFilterSwitch.on)
    }

}
