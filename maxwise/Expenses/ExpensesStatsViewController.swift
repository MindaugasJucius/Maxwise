//
//  ExpensesStatsViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/17/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class ExpensesStatsViewController: UIViewController {

    var amount: String = "" {
        didSet {
            amountLabel.text = "Total amount spent: \(amount)"
        }
    }
    
    @IBOutlet private weak var blurView: BlurView!
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.contentView.addSubview(amountLabel)
        amountLabel.fill(in: blurView.contentView)
    }

}
