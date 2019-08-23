//
//  ExpenseCategorySelectionViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 8/23/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit
import ExpenseKit

class ExpenseCategorySelectionViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var emojiLabel: UILabel!
    
    private let categories: [ExpenseCategory]
    
    init(categories: [ExpenseCategory]) {
        self.categories = categories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.applyBorder()
        view.layer.borderColor = UIColor.clear.cgColor
        categoryLabel.font = .systemFont(ofSize: 8, weight: .bold)
        containerView.layer.applyBorder()
        configureForCategory()
    }
    
    private func configureForCategory() {
        guard let preselectedCategoryID = UserDefaults.standard.string(forKey: ExpenseCategoryModelController.preselectedCategoryKey),
            let category = categories.filter ({ $0.id == preselectedCategoryID }).first else {
                fatalError()
        }
        
        containerView.backgroundColor = category.color?.withAlphaComponent(0.1)
        containerView.layer.borderColor = category.color?.withAlphaComponent(0.4).cgColor
        emojiLabel.text = category.emojiValue

        if let shadowColor = category.color {
            view.layer.applyShadow(color: shadowColor)
        }
    }
    
}
