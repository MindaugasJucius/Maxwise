import UIKit

class NavigationView: UIView {
    
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    init() {
        super.init(frame: .zero)
        loadNib()
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
