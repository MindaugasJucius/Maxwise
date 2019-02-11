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
        amountLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .darkGray
        backgroundColor = .clear
        
    }

    func configure(expenseDTO: ExpensePresentationDTO) {
        amountLabel.text = expenseDTO.currencyAmount
        titleLabel.text = expenseDTO.title
        dateLabel.text = expenseDTO.formattedDate
        expenseImageView.image = expenseDTO.image
    }
    
}
