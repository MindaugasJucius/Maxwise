//
//  BlurLabelView.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/7/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class BlurView: UIVisualEffectView {
    
    static var defaultBackgroundColor = UIColor.white.withAlphaComponent(0.6)

    var borderColor: UIColor? {
        didSet {
            guard let color = borderColor else {
                return
            }
            layer.borderWidth = 1
            layer.borderColor = color.cgColor
        }
    }
    
    
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
        backgroundColor = BlurView.defaultBackgroundColor
        layer.cornerRadius = 6
    }
    
}
