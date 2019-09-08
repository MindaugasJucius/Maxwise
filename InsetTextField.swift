//
//  InsetTextField.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 9/8/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class InsetTextField: UITextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 10, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 10, dy: 0)
    }
}
