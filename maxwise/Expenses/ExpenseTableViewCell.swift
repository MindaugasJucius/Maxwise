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
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var expenseImageView: UIImageView!
    @IBOutlet private weak var roundedView: UIView!
    
    private lazy var roundedLayer: CALayer = {
        let layer = CALayer.init()
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 6
        return layer
    }()
    
    override var frame: CGRect {
        didSet {
            roundedLayer.frame = bounds.inset(by: layoutMargins)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)

        locationLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        locationLabel.textColor = .gray
        
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .lightGray

        amountLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        amountLabel.textColor = .darkGray
        
        backgroundColor = .clear
        accessoryType = .disclosureIndicator
        layer.insertSublayer(roundedLayer, at: 0)
    }

    func configure(expenseDTO: ExpensePresentationDTO) {
        amountLabel.text = expenseDTO.currencyAmount
        titleLabel.text = expenseDTO.title
        locationLabel.text = expenseDTO.locationTitle
        dateLabel.text = expenseDTO.formattedDate
        expenseImageView.image = expenseDTO.image
    }
    
}
