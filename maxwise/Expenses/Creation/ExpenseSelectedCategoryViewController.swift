import UIKit
import ExpenseKit

class ExpenseSelectedCategoryViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var emojiLabel: UILabel!
    
    private let categories: [ExpenseCategory]
    private let selectedCategory: (ExpenseCategory) -> ()
    
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
        view.layer.applyBorder()
        view.layer.borderColor = UIColor.clear.cgColor
        containerView.layer.applyBorder()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        containerView.addGestureRecognizer(tapGesture)

        guard let preselectedCategoryID = UserDefaults.standard.string(forKey: ExpenseCategoryModelController.preselectedCategoryKey),
            let category = categories.filter ({ $0.id == preselectedCategoryID }).first else {
                fatalError()
        }
        configure(for: category)
        selectedCategory(category)
    }
    
    @objc private func tap() {
        let selectionVC = ExpenseCategorySelectionViewController(categories: categories) { [weak self] selectedCategory in
            self?.dismiss(animated: true, completion: nil)
            self?.configure(for: selectedCategory)
            self?.selectedCategory(selectedCategory)
            UserDefaults.standard.setValue(selectedCategory.id,
                                           forKey: ExpenseCategoryModelController.preselectedCategoryKey)
        }
        
        let navigationController = UINavigationController(rootViewController: selectionVC)
        navigationController.navigationBar.prefersLargeTitles = true
        present(navigationController, animated: true, completion: nil)
    }
    
    private func configure(for category: ExpenseCategory) {
        containerView.backgroundColor = category.color?.withAlphaComponent(0.1)
        containerView.layer.borderColor = category.color?.withAlphaComponent(0.4).cgColor
        emojiLabel.text = category.emojiValue
        if let shadowColor = category.color {
            view.layer.applyShadow(color: shadowColor)
        }
    }
}
