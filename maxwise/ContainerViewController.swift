import UIKit
import ExpenseKit

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

        let categoriesViewController = CategoriesParentViewController()

        categoriesViewController.tabBarItem = UITabBarItem.init(title: "Categories",
                                                                image: UIImage(systemName: "chart.pie.fill"),
                                                                tag: 0)
        expensesViewController.tabBarItem = UITabBarItem.init(title: "Expenses",
                                                              image: UIImage.init(systemName: "list.bullet"),
                                                              tag: 0)
        
        setViewControllers([expensesViewController, categoriesViewController], animated: false)
        
        
        ExpenseCategoryModelController().addDefaultCategoriesIfNeeded()
        ColorModelController().savePaletteColors {
            print("Completed persisting color palette")
        }
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

