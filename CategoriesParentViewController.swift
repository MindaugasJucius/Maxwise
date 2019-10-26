import UIKit
import ExpenseKit

class CategoriesParentViewController: UINavigationController {

    private let expenseCategoryModelController = ExpenseCategoryModelController()
    
    private lazy var createCategoryButton: UIButton = {
        let button = UIButton.init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentCreationVC), for: .touchUpInside)
        return button
    }()
    
    lazy var statisticsViewController = CategoriesStatisticsViewController.init(
        choseToViewExpensesForCategory: { [weak self] (categoryStatsDTO, sectionIdentifier) in
            let viewModel = HardcodedExpensesViewModel.init(categoryID: categoryStatsDTO.categoryID,
                                                            date: sectionIdentifier)
            let expensesVC = ExpensesViewController(viewModel: viewModel)
            expensesVC.title = categoryStatsDTO.categoryTitle
            self?.pushViewController(expensesVC, animated: true)
        },
        choseToEditCategory: { [weak self] categoryID in
            guard let category = self?.expenseCategoryModelController.category(from: categoryID) else {
                print("no category fetched when trying to edit category")
                return
            }
            self?.presentCategoryCreation(for: category)
        },
        choseToDeleteCategory: { [weak self] categoryID in
            self?.presentAreYouSure(categoryID: categoryID)
        }
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.prefersLargeTitles = true
        viewControllers = [statisticsViewController]
        navigationBar.addSubview(createCategoryButton)
        delegate = self
        let constraints = [
            navigationBar.rightAnchor.constraint(equalTo: createCategoryButton.rightAnchor, constant: 25),
            navigationBar.bottomAnchor.constraint(equalTo: createCategoryButton.bottomAnchor, constant: 10),
            createCategoryButton.widthAnchor.constraint(equalToConstant: 35),
            createCategoryButton.heightAnchor.constraint(equalTo: createCategoryButton.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func presentCreationVC() {
        presentCategoryCreation(for: ExpenseCategory.init())
    }
    
    private func presentCategoryCreation(for category: ExpenseCategory) {
        let creationVC = CategoryCreationViewController(category: category)
        present(creationVC, animated: true, completion: nil)
    }

    private func presentAreYouSure(categoryID: String) {
        showAlert(
            title: "Are you sure?",
            message: "Deleting this category will delete it's expenses.",
            ok: { [weak self] _ in
                self?.expenseCategoryModelController.removeCategory(with: categoryID)
            },
            cancel: { _ in }
        )
    }
    
    private func updateNavigationBarButtonImage(for viewController: UIViewController) {
        let imageName: String
        
        if viewController is CategoriesStatisticsViewController {
            imageName = "plus.circle.fill"
        } else {
            imageName = "ellipsis.circle.fill"
        }
        
        let image = UIImage(
            systemName: imageName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 25)
        )
        
        createCategoryButton.setImage(image, for: .normal)
    }
}

extension CategoriesParentViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateNavigationBarButtonImage(for: viewController)
    }
    
}
