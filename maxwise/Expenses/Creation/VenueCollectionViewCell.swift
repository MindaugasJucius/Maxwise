//
//  VenueCollectionViewCell.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 3/2/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class VenueCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var venueNameLabel: UILabel!
    @IBOutlet private weak var venueInfoLabel: UILabel!
    @IBOutlet private weak var venueCategoryImageVIew: UIImageView!
    @IBOutlet private weak var blurView: BlurView!
    @IBOutlet private weak var labelStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        venueInfoLabel.lineBreakMode = .byWordWrapping
        venueNameLabel.lineBreakMode = .byWordWrapping
        blurView.borderColor = .white
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                if self.isSelected {
                    self.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
                    self.blurView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
                } else {
                    self.transform = CGAffineTransform.identity
                    self.blurView.backgroundColor = BlurView.defaultBackgroundColor
                }
            })
        }
    }
    
    func update(venue: NearbyPlace) {
        venueNameLabel.text = venue.title
        venueInfoLabel.text = venue.categoryTitle
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let cellWidthWithoutLabels: CGFloat = 80
        
        guard let infoText = venueInfoLabel.text as NSString?,
            let nameText = venueNameLabel.text as NSString? else {
            return super.preferredLayoutAttributesFitting(layoutAttributes)
        }
        
        let infoTextAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: venueInfoLabel.font]
        let nameTextAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: venueNameLabel.font]
        
        let infoTextSize = infoText.size(withAttributes: infoTextAttributes)
        let nameTextSize = nameText.size(withAttributes: nameTextAttributes)
        
        let maxWidth = max(ceil(infoTextSize.width), ceil(nameTextSize.width))
        layoutAttributes.size = CGSize.init(width: maxWidth + cellWidthWithoutLabels, height: layoutAttributes.size.height)
        
        return layoutAttributes
    }

}
