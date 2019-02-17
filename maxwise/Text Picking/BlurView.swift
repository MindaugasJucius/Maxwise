//
//  BlurLabelView.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/7/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class BlurView: UIVisualEffectView {
    
    init() {
        let blurEffect = UIBlurEffect(style: .light)
        super.init(effect: blurEffect)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        effect = UIBlurEffect(style: .light)
        configure()
    }
    
    private func configure() {
        backgroundColor = UIColor.white.withAlphaComponent(0.6)
        clipsToBounds = true
        layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
    }
    
}