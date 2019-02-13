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
    private lazy var roundedView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 6
        return view
    }()
        
    override func awakeFromNib() {
        super.awakeFromNib()
        amountLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .darkGray
        backgroundColor = .clear
        print(contentView.layoutMarginsGuide)
        print(contentView.readableContentGuide)
        configureRoundedView()
    }

    func configure(expenseDTO: ExpensePresentationDTO) {
        amountLabel.text = expenseDTO.currencyAmount
        titleLabel.text = expenseDTO.title
        dateLabel.text = expenseDTO.formattedDate
        expenseImageView.image = expenseDTO.image
    }
    
    private func configureRoundedView() {
        contentView.insertSubview(roundedView, at: 0)
        let multiplier = CGFloat(0.5)
        let constraints = [
            roundedView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.readableContentGuide.leadingAnchor, multiplier: multiplier),
            contentView.readableContentGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: roundedView.trailingAnchor, multiplier: multiplier),
            contentView.readableContentGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: roundedView.bottomAnchor, multiplier: multiplier),
            roundedView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.readableContentGuide.topAnchor, multiplier: multiplier)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}
