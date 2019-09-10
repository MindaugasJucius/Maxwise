import UIKit
import ExpenseKit

class ExpenseCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!

    private var category: ExpenseCategory?
    private lazy var selectionView = UIView()
    
    func configure(category: ExpenseCategory) {
        categoryTitleLabel.text = category.title
        emojiLabel.text = category.emojiValue
        selectionView.backgroundColor = category.color?.uiColor?.withAlphaComponent(0.3)
        selectedBackgroundView = selectionView
        self.category = category
    }
    
}
