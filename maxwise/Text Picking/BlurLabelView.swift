//
//  BlurLabelView.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/7/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class BlurLabelView: UIVisualEffectView {

    init(text: String) {
        let blurEffect = UIBlurEffect(style: .light)
        super.init(effect: blurEffect)
        configure()
        addLabel(text: text)
    }
    
    private func configure() {
        backgroundColor = UIColor.white.withAlphaComponent(0.6)
        clipsToBounds = true
        layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 6
    }
    
    private func addLabel(text: String) {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        contentView.addSubview(label)
        label.fill(in: contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIView {
    
    func fill(in view: UIView) {
        guard view == superview,
            let superview = superview else {
            fatalError("wrong superview")
        }
        let constraints = [
            leadingAnchor.constraint(equalToSystemSpacingAfter: superview.leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: superview.trailingAnchor, multiplier: 1),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}
