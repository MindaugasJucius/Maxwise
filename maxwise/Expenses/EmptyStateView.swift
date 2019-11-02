import UIKit

enum EmptyViewState {
    case shown(EmptyViewConfiguration)
    case hidden
}

struct EmptyViewConfiguration {
    let topString: String
    let bottomString: String
    let image: UIImage?
}

class EmptyStateView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    init() {
        super.init(frame: .zero)
        loadNib()
        configure()
    }
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
        configure()
    }
    
    private func configure() {
        isUserInteractionEnabled = false
        topLabel.font = .systemFont(ofSize: 25, weight: .medium)
//        topLabel.text = "There's nothing added!"
        topLabel.textColor = .secondaryLabel
        
        bottomLabel.textColor = .tertiaryLabel
        bottomLabel.font = .systemFont(ofSize: 20, weight: .regular)
//        bottomLabel.text = "Start by tapping below"
        
        imageView.tintColor = .secondaryLabel
    }
    
    func configure(with configuration: EmptyViewConfiguration) {
        topLabel.text = configuration.topString
        bottomLabel.text = configuration.bottomString
        imageView.image = configuration.image
        imageView.isHidden = configuration.image == nil
    }
        
}
