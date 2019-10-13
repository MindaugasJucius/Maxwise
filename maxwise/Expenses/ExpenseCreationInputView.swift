import UIKit
import ExpenseKit

class ExpenseCreationInputView: UIInputView {

    private lazy var createButton: BeautifulButton = {
        let button = BeautifulButton.init()
        button.updateAppearances(backgroundColor: .confirmationGreen, textColor: .confirmationGreen)
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.font = font
        button.setTitle("Add expense", for: .normal)
        button.tintColor = .white
        
        let image = UIImage(systemName: "checkmark.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(font: font))
        
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        
        button.addTarget(self, action: #selector(createAction), for: .touchUpInside)

        button.imageEdgeInsets = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 0,
                                              right: 8)
        return button
    }()

    @IBOutlet weak var rightContentView: UIView!
    
    private var closeButtonAction: (() -> ())?
    private var createButtonAction: (() -> ())?
    
    static func create(closeButton: @escaping () -> (),
                       createButton: @escaping () -> ()) -> ExpenseCreationInputView? {
        let nibName = String(describing: ExpenseCreationInputView.self)
        let nib = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)
        let inputView = nib?.first as? ExpenseCreationInputView
        inputView?.createButtonAction = createButton
        inputView?.closeButtonAction = closeButton
        return inputView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rightContentView.addSubview(createButton)
        createButton.fillInSuperview()
    }

    func update(for color: UIColor) {
        createButton.updateAppearances(backgroundColor: color, textColor: color)
    }
    
    private func button(imageName: String, title: String) -> UIButton {
        let button = UIButton.init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title.uppercased(), for: .normal)
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.font = font
        
        let image = UIImage(systemName: imageName,
                            withConfiguration: UIImage.SymbolConfiguration(font: font))
        button.setImage(image, for: .normal)

        return button
    }
    
    @objc private func closeAction() {
        closeButtonAction?()
    }

    @objc private func createAction() {
        createButtonAction?()
    }
}
