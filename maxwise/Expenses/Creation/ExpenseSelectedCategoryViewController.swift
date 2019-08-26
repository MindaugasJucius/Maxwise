import UIKit
import ExpenseKit

class ExpenseSelectedCategoryViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var emojiLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private let categories: [ExpenseCategory]
    
    init(categories: [ExpenseCategory]) {
        self.categories = categories
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
        configureForCategory()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tap() {
//        present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
    
    private func configureForCategory() {
        guard let preselectedCategoryID = UserDefaults.standard.string(forKey: ExpenseCategoryModelController.preselectedCategoryKey),
            let category = categories.filter ({ $0.id == preselectedCategoryID }).first else {
                fatalError()
        }

        containerView.backgroundColor = category.color?.withAlphaComponent(0.1)
        containerView.layer.borderColor = category.color?.withAlphaComponent(0.4).cgColor
        emojiLabel.text = category.emojiValue
        titleLabel.text = category.title.uppercased()
        titleLabel.textColor = category.color
        if let shadowColor = category.color {
            view.layer.applyShadow(color: shadowColor)
        }
    }
}
