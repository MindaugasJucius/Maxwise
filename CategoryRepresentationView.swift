import UIKit
import ExpenseKit

class CategoryRepresentationView: UIView {

    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    init() {
        super.init(frame: .zero)
        loadNib()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        configure()
    }
    
    func configure() {
        emojiTextField.layer.applyBorder()
        containerView.layer.cornerRadius = 6
        containerView.layer.cornerCurve = .continuous
        emojiTextField.layer.applyBorder()
    }

    func update(for uiColor: UIColor) {
        emojiTextField.tintColor = uiColor
        emojiTextField.backgroundColor = uiColor.withAlphaComponent(0.1)
        emojiTextField.layer.borderColor = uiColor.cgColor
        containerView.layer.applyShadow(color: uiColor)
    }
}
