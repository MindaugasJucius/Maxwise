import UIKit
import ExpenseKit

class ExpenseCreationInputView: UIInputView {

    private lazy var createButton: BeautifulButton = {
        let button = BeautifulButton.init()
        button.updateAppearances(backgroundColor: .confirmationGreen, textColor: .confirmationGreen)
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.font = font
        button.tintColor = .white
        button.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        return button
    }()

    @IBOutlet weak var rightContentView: UIView!
    
    private var closeButtonAction: (() -> ())?
    private var createButtonAction: (() -> ())?
    
    static func create(title: String,
                       closeButton: @escaping () -> (),
                       createButton: @escaping () -> ()) -> ExpenseCreationInputView? {
        let nibName = String(describing: ExpenseCreationInputView.self)
        let nib = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)
        let inputView = nib?.first as? ExpenseCreationInputView
        inputView?.createButtonAction = createButton
        inputView?.closeButtonAction = closeButton
        inputView?.createButton.setTitle(title, for: .normal)
        
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

    @objc private func closeAction() {
        closeButtonAction?()
    }

    @objc private func createAction() {
        createButtonAction?()
    }
}
