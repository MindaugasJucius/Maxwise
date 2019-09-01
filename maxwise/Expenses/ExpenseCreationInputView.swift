import UIKit

class ExpenseCreationInputView: UIInputView {

    private lazy var closeButton: UIButton = {
        let closeButton = button(imageName: "xmark.circle.fill", title: "CLOSE")
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return closeButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = button(imageName: "checkmark.circle.fill", title: "CREATE")
        createButton.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        return createButton
    }()

    @IBOutlet weak var leftContentView: VibrantContentView!
    @IBOutlet weak var rightContentView: VibrantContentView!
    
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
        closeButton.tintColor = .red
        closeButton.setTitleColor(.red, for: .normal)
        createButton.tintColor = .green
        createButton.setTitleColor(.green, for: .normal)
        
        leftContentView.configuration = VibrantContentView.Configuration(cornerStyle: .rounded,
                                                                                  blurEffectStyle: .prominent)
        
        rightContentView.configuration = VibrantContentView.Configuration(cornerStyle: .rounded,
                                                                         blurEffectStyle: .prominent)
        
        leftContentView.contentView?.addSubview(closeButton)
        leftContentView.contentView?.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        closeButton.fillInSuperview()

        rightContentView.contentView?.addSubview(createButton)
        rightContentView.contentView?.backgroundColor = UIColor.green.withAlphaComponent(0.1)
        createButton.fillInSuperview()
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
