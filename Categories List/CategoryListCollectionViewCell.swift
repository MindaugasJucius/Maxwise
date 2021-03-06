import UIKit
import ExpenseKit

class CategoryListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var targetedPreviewView: UIView!
    @IBOutlet weak var percentageAmountSpentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var percentageAmountSpentView: UIView!
    @IBOutlet private weak var categoryRepresentationView: CategoryRepresentationView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var amountSpentInCategoryLabel: UILabel!
    
    @IBOutlet private weak var cellSeparatorView: UIView!
    @IBOutlet private weak var cellSeparatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var cellBackgroundView: UIView!
    @IBOutlet weak var chevronImageView: UIImageView!
    
    private var representedDTO: ExpenseCategoryStatsDTO?
    private var newWidth: CGFloat = 0
    
    private var isCurrentlyAnimating = false
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
        chevronImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.7)
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
    
    func highlightCell() {
        guard !isCurrentlyAnimating else {
            return
        }
        
        let animator = UIViewPropertyAnimator.init(duration: 0.3, curve: .easeInOut)
        animator.addAnimations {
            self.contentView.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
            self.cellBackgroundView.backgroundColor = self.representedDTO?.color
        }
        animator.addCompletion { position in
            guard position == .end else {
                return
            }
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    self.contentView.transform = CGAffineTransform.identity
                    self.cellBackgroundView.backgroundColor = .secondarySystemGroupedBackground
                },
                completion: { _ in
                    self.isCurrentlyAnimating = false
                }
            )
        }
        animator.startAnimation()
        isCurrentlyAnimating = true
    }

    func roundTop() {
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func roundBottom() {
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cellSeparatorView.isHidden = true
    }
    
    // When section has a single cell
    func roundEverything() {
        layer.maskedCorners = [.layerMaxXMinYCorner,
                               .layerMinXMinYCorner,
                               .layerMinXMaxYCorner,
                               .layerMaxXMaxYCorner]
        cellSeparatorView.isHidden = true
    }
}
