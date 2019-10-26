import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var shareAmountLabel: UILabel!
    @IBOutlet private weak var shareAmountLabelExplanation: UILabel!
    @IBOutlet private weak var categoryEmojiLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .label

        shareAmountLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)

        shareAmountLabelExplanation.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        shareAmountLabelExplanation.text = "You spent".uppercased()
        
        amountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        amountLabel.textColor = .tertiaryLabel
        
        selectionStyle = .blue
        accessoryType = .disclosureIndicator
        separatorInset = .zero
    }
    
    func configure(expenseDTO: ExpensePresentationDTO) {
        categoryEmojiLabel.text = expenseDTO.categoryEmojiValue
        amountLabel.text = "Total: \(expenseDTO.currencyAmount)"
        shareAmountLabel.text = expenseDTO.sharePercentageCurrencyAmount
        titleLabel.text = expenseDTO.title
        shareAmountLabel.textColor = expenseDTO.categoryColor?.withAlphaComponent(0.9)
        shareAmountLabelExplanation.textColor = expenseDTO.categoryColor?.withAlphaComponent(0.7)
    }
    
}
