import UIKit
import ExpenseKit

class ExpenseCreationParentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    }
    
    func expenseCreation() -> UIViewController {
        let viewModel = ExpenseCreationViewModel()

        let expenseCreationViewController = ExpenseCreationViewController(viewModel: viewModel)
        return expenseCreationViewController
    }
    
}
