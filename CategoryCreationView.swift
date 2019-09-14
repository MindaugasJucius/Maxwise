import UIKit
import ExpenseKit

class CategoryCreationView: UIView {

    private let expenseCategory: ExpenseCategory
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryEmojiTextField: UITextField!
    
    init(expenseCategory: ExpenseCategory) {
        self.expenseCategory = expenseCategory
        super.init(frame: .zero)
        loadNib()
        configure(expenseCategory: expenseCategory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(expenseCategory: ExpenseCategory) {
        layer.masksToBounds = true
        layer.applyShadow(color: .tertiaryLabel)
        titleTextField.becomeFirstResponder()
        
        colorView.layer.cornerCurve = .circular
        colorView.layer.cornerRadius = colorView.frame.width / 2
        colorView.layer.borderWidth = 2
        colorView.layer.borderColor = UIColor.gray.cgColor

        titleTextField.layer.applyBorder()
        titleTextField.layer.borderColor = UIColor.clear.cgColor
        titleTextField.textColor = .label
        titleTextField.placeholder = "Category title"
        titleTextField.autocapitalizationType = .words
        titleTextField.addTarget(self, action: #selector(resetErrorStates), for: .editingChanged)
        titleTextField.delegate = self
        
        if !expenseCategory.isEmpty() {
            titleTextField.text = expenseCategory.title
            colorView.layer.backgroundColor = expenseCategory.color?.uiColor?.cgColor
            categoryEmojiTextField.text = expenseCategory.emojiValue
        }
    }
    
    private func loadNib() {
        let nib = Bundle.main.loadNibNamed(CategoryCreationView.nibName, owner: self, options: nil)
        guard let contentView = nib?.first as? UIView else {
            fatalError("view in nib not found")
        }
        addSubview(contentView)
        contentView.fill(in: self)
        
        contentView.layer.cornerCurve = .continuous
        contentView.layer.cornerRadius = 6
    }

    func isCategoryDataValid() -> Bool {
        guard let titleText = titleTextField.text, !titleText.isEmpty else {
            titleTextField.layer.borderColor = UIColor.red.cgColor
            return false
        }
        return true
    }
    
    @objc private func resetErrorStates() {
        titleTextField.layer.borderColor = UIColor.clear.cgColor
    }
}

extension CategoryCreationView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }

        if (text + string).count > 30 {
            return false
        }
        
        return true
    }
    
}
