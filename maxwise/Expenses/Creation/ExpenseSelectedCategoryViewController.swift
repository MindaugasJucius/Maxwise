import UIKit
import ExpenseKit

class ExpenseSelectedCategoryViewController: UIViewController {
    
    private let categories: [ExpenseCategory]
    private let selectedCategory: (ExpenseCategory) -> ()
    
    @IBOutlet weak var categoryRepresentationView: CategoryRepresentationView!
    
    init(categories: [ExpenseCategory], selectedCategory: @escaping (ExpenseCategory) -> ()) {
        self.categories = categories
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        categoryRepresentationView.addGestureRecognizer(tapGesture)
        categoryRepresentationView.emojiTextField.isEnabled = false
        
        guard let preselectedCategoryID = ExpenseCategoryModelController.preselectedCategoryID,
            let category = categories.filter ({ $0.id == preselectedCategoryID }).first else {
                print("failed to find preselected category")
                return
        }
        configure(for: category)
        selectedCategory(category)
    }
    
    @objc private func tap() {
        let selectionVC = ExpenseCategorySelectionViewController(categories: categories) { [weak self] selectedCategory in
            self?.dismiss(animated: true, completion: nil)
            self?.configure(for: selectedCategory)
            self?.selectedCategory(selectedCategory)
            ExpenseCategoryModelController.preselectedCategoryID = selectedCategory.id
        }
        
        let navigationController = UINavigationController(rootViewController: selectionVC)
        navigationController.navigationBar.prefersLargeTitles = true
        present(navigationController, animated: true, completion: nil)
    }
    
    private func configure(for category: ExpenseCategory) {
        categoryRepresentationView.emojiTextField.text = category.emojiValue
        guard let categoryColor = category.color?.uiColor else {
            return
        }
        categoryRepresentationView.update(for: categoryColor)
    }
}
