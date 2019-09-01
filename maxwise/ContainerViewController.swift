import UIKit

enum Screen {
    case expenseCreation
}

protocol PresentationViewControllerDelegate: class {
    func show(screen: Screen)
}

class ContainerViewController: UITabBarController {

    private lazy var expensesViewController = ExpensesParentViewController(presentationDelegate: self)
    private lazy var expenseCreationParentViewController = ExpenseCreationParentViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true

        let categoriesViewController = UIViewController(nibName: nil, bundle: nil)

        categoriesViewController.tabBarItem = UITabBarItem.init(title: "Categories",
                                                                image: UIImage(systemName: "chart.pie.fill"),
                                                                tag: 0)
        
        setViewControllers([expensesViewController, categoriesViewController], animated: false)
        expensesViewController.tabBarItem = UITabBarItem.init(tabBarSystemItem: .mostViewed, tag: 0)
        expensesViewController.tabBarItem.title = "Expenses"
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

