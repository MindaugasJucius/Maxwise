//
//  ExpensesSectionHeaderView.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 8/14/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class ExpensesSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private weak var label: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(title: String) {
        label.text = title
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 25, weight: .medium)
    }
}
