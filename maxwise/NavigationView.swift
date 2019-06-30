import UIKit

class NavigationView: UIView {
    
    @IBOutlet private weak var centeredButton: UIButton!

    var buttonTapped: EmptyCallback?
    
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
    
    private func loadNib() {
        let nib = Bundle.main.loadNibNamed(NavigationView.nibName, owner: self, options: nil)
        guard let contentView = nib?.first as? UIView else {
            fatalError("view in nib not found")
        }
        addSubview(contentView)
        contentView.fill(in: self)
    }
    
    private func configureButtons() {
        centeredButton.addTarget(self, action: #selector(tappedButton), for: .touchUpInside)
        centeredButton.setTitle("", for: .normal)
        centeredButton.setImage(#imageLiteral(resourceName: "add"), for: .normal)
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
