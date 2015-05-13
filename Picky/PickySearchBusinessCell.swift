//
//  PickySearchBusinessCell.swift
//  Picky
//
//  Created by Francisco de la Pena on 5/12/15.
//  Copyright (c) 2015 Twister Labs, LLC. All rights reserved.
//

import UIKit

class PickySearchBusinessCell: UITableViewCell {
    
    
    @IBOutlet var thumbImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var ratingImageView: UIImageView!
    
    @IBOutlet var reviewsCountLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var categoriesLabel: UILabel!
    
    @IBOutlet var dealLabel: UILabel!
    
    var business: Business! {
        didSet{
            thumbImageView.setImageWithURL(business.imageURL)
            nameLabel.text = business.name
            distanceLabel.text = business.distance
            ratingImageView.setImageWithURL(business.ratingImageURL)
            reviewsCountLabel.text = "\(business.reviewCount!) reviews"
            addressLabel.text = business.address
            categoriesLabel.text = business.categories
            self.backgroundColor = business.deals! ?  UIColor.redColor().colorWithAlphaComponent(0.3) : UIColor.whiteColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryType.None
        thumbImageView.layer.cornerRadius = 5
        thumbImageView.clipsToBounds = true
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
        addressLabel.preferredMaxLayoutWidth = addressLabel.frame.size.width
        categoriesLabel.preferredMaxLayoutWidth = categoriesLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}