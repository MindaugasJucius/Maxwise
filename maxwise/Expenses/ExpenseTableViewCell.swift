//
//  ExpenseTableViewCell.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/10/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var expenseImageView: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        expenseImageView.contentMode = .scaleToFill
    }

    func configure(expenseDTO: ExpenseEntryDTO) {
        amountLabel.text = String(expenseDTO.amount)
        titleLabel.text = expenseDTO.title
        dateLabel.text = expenseDTO.date
        expenseImageView.image = expenseDTO.image
    }
    
}
