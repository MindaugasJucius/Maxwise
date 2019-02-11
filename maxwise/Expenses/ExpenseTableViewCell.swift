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
        
    }

    func configure(expenseDTO: ExpensePresentationDTO) {
        amountLabel.text = expenseDTO.currencyAmount
        titleLabel.text = expenseDTO.title
        dateLabel.text = expenseDTO.formattedDate
        expenseImageView.image = expenseDTO.image
    }
    
}
