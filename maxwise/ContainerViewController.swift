import UIKit

enum Screen {
    case expenses
    case expenseCreation
}

protocol PresentationViewControllerDelegate {
    func show(screen: Screen)
}

class ContainerViewController: UIPageViewController {

    private lazy var expensesViewController = ExpensesParentViewController()
    private lazy var expenseCreationParentViewController = ExpenseCreationParentViewController()
    
    private lazy var initialViewControllers: [UIViewController] = [expensesViewController]
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        dataSource = self
        setViewControllers(initialViewControllers, direction: .forward, animated: false, completion: nil)
        addNavigationView()
    }
    
    private func addNavigationView() {
        let navigationView = NavigationView()
        navigationView.buttonTapped = { [weak self] in
            self?.show(screen: .expenseCreation)
        }
        navigationView.move(to: view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let viewModel = ExpenseCreationViewModel(nearbyPlaces: [])
        let expenseCreationVC = ExpenseCreationViewController(viewModel: viewModel)
        present(expenseCreationVC, animated: true, completion: nil)
    }

}

extension ContainerViewController: PresentationViewControllerDelegate {
    
    func show(screen: Screen) {
        switch screen {
        case .expenses:
            setViewControllers([expensesViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        case .expenseCreation:
            let vc = expenseCreationParentViewController.expenseCreation()
            present(vc, animated: true, completion: nil)
        }
    }
    
}

extension ContainerViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = initialViewControllers.firstIndex(of: viewController)
        
        guard let currentIndex = index, currentIndex > 0 else {
            return nil
        }
        
        return initialViewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = initialViewControllers.firstIndex(of: viewController)
        
        guard let currentIndex = index else {
            return nil
        }
        
        let newIndex = currentIndex + 1
        
        guard newIndex < initialViewControllers.count else {
            return nil
        }
        
        return initialViewControllers[newIndex]
    }

}
