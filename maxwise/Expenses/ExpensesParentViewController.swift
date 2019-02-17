//
//  ExpensesParentViewController.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/17/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import UIKit

class ExpensesParentViewController: UINavigationController {

    private let expensesViewModel = ExpensesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        viewControllers = [ExpensesViewController(viewModel: expensesViewModel)]
    }

}
