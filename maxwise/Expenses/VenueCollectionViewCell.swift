//
//  VenueCollectionViewCell.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 3/2/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class VenueCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueInfoLabel: UILabel!
    @IBOutlet weak var venueCategoryImageVIew: UIImageView!
    //@IBOutlet weak var containerBlurView: BlurView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
    }

}
