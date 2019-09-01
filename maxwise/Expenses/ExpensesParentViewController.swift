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
    private weak var presentationDelegate: PresentationViewControllerDelegate?
    
    init(presentationDelegate: PresentationViewControllerDelegate) {
        self.presentationDelegate = presentationDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        viewControllers = [ExpensesViewController(viewModel: expensesViewModel,
                                                  presentationDelegate: presentationDelegate)]
    }

}
