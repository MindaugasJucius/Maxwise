import UIKit

class NavigationView: UIView {
    
    @IBOutlet private weak var centeredButton: UIButton!

    var buttonTapped: (() -> ())?
    
    init() {
        super.init(frame: .zero)
        loadNib()
        configureButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        configureButtons()
    }
    
    private func configureButtons() {
        centeredButton.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        centeredButton.setTitle("", for: .normal)

        let image = UIImage.init(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: 50))
        centeredButton.setImage(image, for: .normal)
    }
    
    @objc private func tappedButton() {
        buttonTapped?()
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
