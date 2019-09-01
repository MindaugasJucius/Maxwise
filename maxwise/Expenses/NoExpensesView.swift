import UIKit

class NoExpensesView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    init() {
        super.init(frame: .zero)
        loadNib()
        configure()
    }
   
    private func configure() {
        isUserInteractionEnabled = false
        topLabel.font = .systemFont(ofSize: 25, weight: .medium)
        topLabel.text = "You have no expenses"
        topLabel.textColor = .secondaryLabel
        
        bottomLabel.textColor = .tertiaryLabel
        bottomLabel.font = .systemFont(ofSize: 20, weight: .regular)
        bottomLabel.text = "Start by tapping down below"
        
        imageView.tintColor = .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadNib() {
        let nib = Bundle.main.loadNibNamed(NoExpensesView.nibName, owner: self, options: nil)
        guard let contentView = nib?.first as? UIView else {
            fatalError("view in nib not found")
        }
        addSubview(contentView)
        contentView.fill(in: self)
    }
    
}
