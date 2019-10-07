import UIKit
import ExpenseKit

class CategoryListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var percentageAmountSpentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var percentageAmountSpentView: UIView!
    @IBOutlet weak var categoryRepresentationView: CategoryRepresentationView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var amountSpentInCategoryLabel: UILabel!
    
    private var representedDTO: ExpenseCategoryStatsDTO?
    private var newWidth: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        categoryTitleLabel.textColor = .label
        amountSpentInCategoryLabel.textColor = .secondaryLabel
        percentageAmountSpentViewWidthConstraint.constant = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let dto = representedDTO else {
            return
        }
        let width = frame.width * CGFloat(dto.percentageOfAmountInDateRange)
        newWidth = width
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        percentageAmountSpentViewWidthConstraint.constant = 0
    }
    
    func setWidth() {
        percentageAmountSpentViewWidthConstraint.constant = newWidth
    }
    
    func update(for category: ExpenseCategoryStatsDTO) {
        categoryTitleLabel.text = category.categoryTitle
        categoryRepresentationView.emojiTextField.text = category.emojiValue
        amountSpentInCategoryLabel.text = category.amountSpentFormatted
        categoryRepresentationView.update(for: category.color)
        representedDTO = category
        percentageAmountSpentView.backgroundColor = category.color.withAlphaComponent(0.3)
    }
    
}
