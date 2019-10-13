import UIKit
import ExpenseKit

class CategoryListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var percentageAmountSpentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var percentageAmountSpentView: UIView!
    @IBOutlet weak var categoryRepresentationView: CategoryRepresentationView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var amountSpentInCategoryLabel: UILabel!
    
    @IBOutlet private weak var cellSeparatorView: UIView!
    @IBOutlet private weak var cellSeparatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellBackgroundView: UIView!
    
    private var representedDTO: ExpenseCategoryStatsDTO?
    private var newWidth: CGFloat = 0
    
    var shouldSetWidthImmediatelly = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        categoryTitleLabel.textColor = .label
        amountSpentInCategoryLabel.textColor = .secondaryLabel
        percentageAmountSpentViewWidthConstraint.constant = 0
        categoryRepresentationView.emojiTextField.isEnabled = false
        cellBackgroundView.backgroundColor = .secondarySystemGroupedBackground
        cellSeparatorView.backgroundColor = .separator
        layer.cornerCurve = .continuous
        layer.cornerRadius = 12
        layer.maskedCorners = []
        cellSeparatorViewHeightConstraint.constant = 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let dto = representedDTO else {
            return
        }
        let width = frame.width * CGFloat(dto.percentageOfAmountInDateRange)
        newWidth = width
        if shouldSetWidthImmediatelly {
            percentageAmountSpentViewWidthConstraint.constant = width
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        percentageAmountSpentViewWidthConstraint.constant = 0
        layer.maskedCorners = []
        cellSeparatorView.isHidden = false
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

    func roundTop() {
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func roundBottom() {
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cellSeparatorView.isHidden = true
    }
}
