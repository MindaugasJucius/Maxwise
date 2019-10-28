import UIKit
import ExpenseKit

class ExpenseSelectedCategoryViewController: UIViewController {
    
    private let categories: [ExpenseCategory]
    private let selectedCategory: (ExpenseCategory) -> ()
    private let preselectedCategory: ExpenseCategory
    
    @IBOutlet weak var categoryRepresentationView: CategoryRepresentationView!
    
    init(categories: [ExpenseCategory],
         categoryToPreselect: ExpenseCategory,
         hasChangedSelectedCategory: @escaping (ExpenseCategory) -> ()) {
        self.categories = categories
        self.preselectedCategory = categoryToPreselect
        self.selectedCategory = hasChangedSelectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        categoryRepresentationView.addGestureRecognizer(tapGesture)
        categoryRepresentationView.emojiTextField.isEnabled = false
        
        configure(for: preselectedCategory)
        selectedCategory(preselectedCategory)
    }
    
    @objc private func tap() {
        let selectionVC = ExpenseCategorySelectionViewController(categories: categories) { [weak self] selectedCategory in
            self?.configure(for: selectedCategory)
            self?.selectedCategory(selectedCategory)
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
