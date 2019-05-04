//
//  UIView+Extensions.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 13/02/2019.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

extension UIView {
    
    func fill(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        guard view == superview,
            let superview = superview else {
                fatalError("wrong superview")
        }
        let constraints = [
            leadingAnchor.constraint(equalToSystemSpacingAfter: superview.leadingAnchor, multiplier: 1),
            superview.trailingAnchor.constraint(equalToSystemSpacingAfter: trailingAnchor, multiplier: 1),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    static var nibName: String {
        return String(describing: self)
    }
    
}
