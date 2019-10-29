import UIKit
import ExpenseKit

class ExpenseCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryRepresentationView: CategoryRepresentationView!
    
    private var category: ExpenseCategory?
    private lazy var selectionView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryRepresentationView.emojiTextField.isEnabled = false
        categoryTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        categoryTitleLabel.textColor = .label
    }
    
    func configure(category: ExpenseCategory) {
        guard let categoryColor = category.color?.uiColor else {
            return
        }
        categoryRepresentationView.update(for: categoryColor)
        
        categoryTitleLabel.text = category.title
        categoryRepresentationView.emojiTextField.text = category.emojiValue
        selectionView.backgroundColor = category.color?.uiColor?.withAlphaComponent(0.3)
        selectedBackgroundView = selectionView
        self.category = category
    }
    
}
