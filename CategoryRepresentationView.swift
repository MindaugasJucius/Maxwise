import UIKit
import ExpenseKit

class CategoryRepresentationView: UIView {

    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    
    private var currentColor: UIColor?
    
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adjustBackgroundColor(for: traitCollection)
    }
    
    func configure() {
        layer.applyBorder()
        layer.borderColor = UIColor.clear.cgColor
        emojiTextField.layer.applyBorder()
        emojiTextField.layer.borderWidth = 1
        containerView.layer.cornerRadius = 6
        containerView.layer.cornerCurve = .continuous
    }

    func update(for uiColor: UIColor) {
        currentColor = uiColor
        emojiTextField.tintColor = uiColor
        adjustBackgroundColor(for: traitCollection)
        emojiTextField.layer.borderColor = uiColor.cgColor
        containerView.layer.applyShadow(color: uiColor)
    }
    
    private func adjustBackgroundColor(for traitCollection: UITraitCollection) {
        if traitCollection.userInterfaceStyle == .dark {
            emojiTextField.backgroundColor = currentColor?.withAlphaComponent(0.2)
        } else {
            emojiTextField.backgroundColor = currentColor?.withAlphaComponent(0.1)
        }
    }
}
