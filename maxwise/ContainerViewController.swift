import UIKit

enum Screen {
    case expenseCreation
}

protocol PresentationViewControllerDelegate {
    func show(screen: Screen)
}

class ContainerViewController: UIViewController {

    private lazy var expensesViewController = ExpensesParentViewController()
    private lazy var expenseCreationParentViewController = ExpenseCreationParentViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    
        addChild(expensesViewController)
        view.addSubview(expensesViewController.view)
        expensesViewController.view.translatesAutoresizingMaskIntoConstraints = false
        expensesViewController.view.fill(in: view)
        expensesViewController.didMove(toParent: nil)

        addNavigationView()
    }
    
    private func addNavigationView() {
        let navigationView = NavigationView()
        navigationView.buttonTapped = { [weak self] in
            self?.show(screen: .expenseCreation)
        }
        navigationView.move(to: view)
    }

}

extension ContainerViewController: PresentationViewControllerDelegate {
    
    func show(screen: Screen) {
        switch screen {
        case .expenseCreation:
            let vc = expenseCreationParentViewController.expenseCreation()
            present(vc, animated: true, completion: nil)
        }
    }
    
}

