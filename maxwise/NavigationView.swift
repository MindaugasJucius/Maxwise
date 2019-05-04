import UIKit

class NavigationView: UIView {
    
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    private var leftButtonTapped: EmptyCallback
    private var rightButtonTapped: EmptyCallback
    
    init(leftButtonTapped: @escaping EmptyCallback,
         rightButtonTapped: @escaping EmptyCallback) {
        self.leftButtonTapped = leftButtonTapped
        self.rightButtonTapped = rightButtonTapped
        super.init(frame: .zero)
        loadNib()
        configureButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadNib() {
        let nib = Bundle.main.loadNibNamed(NavigationView.nibName, owner: self, options: nil)
        guard let contentView = nib?.first as? UIView else {
            fatalError("view in nib not found")
        }
        addSubview(contentView)
        contentView.fill(in: self)
    }
    
    private func configureButtons() {
        leftButton.addTarget(self, action: #selector(tappedLeftButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(tappedRightButton), for: .touchUpInside)
        leftButton.setTitle("Gallery", for: .normal)
        rightButton.setTitle("Expenses", for: .normal)
    }
    
    @objc private func tappedLeftButton() {
        leftButtonTapped()
    }
    
    @objc private func tappedRightButton() {
        rightButtonTapped()
    }
    
    func move(to superview: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self)
        let constraints = [
            leftAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor),
            rightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor),
            superview.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
}
