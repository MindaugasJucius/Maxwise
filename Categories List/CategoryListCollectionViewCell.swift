import UIKit
import ExpenseKit

class CategoryListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryRepresentationView: CategoryRepresentationView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        categoryTitleLabel.textColor = .label
    }
    
    func update(for category: ExpenseCategory) {
        categoryTitleLabel.text = category.title
        categoryRepresentationView.emojiTextField.text = category.emojiValue
        guard let color = category.color else {
            return
        }
        categoryRepresentationView.update(for: color)
    }
    
}
