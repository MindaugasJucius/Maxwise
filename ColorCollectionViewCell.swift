import UIKit
import ExpenseKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            selectionView.isHidden = !isSelected
        }
    }
    
    private lazy var selectionView: UIView = {
        let view = UIView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration.init(weight: .medium)
        let image = UIImage.init(systemName: "checkmark",
                                 withConfiguration: configuration)
        
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .white
        view.addSubview(imageView)
        let constraints = [
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
        ]
        NSLayoutConstraint.activate(constraints)
        

        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()

    private lazy var alreadyTakenView: UIView = {
        let view = UIView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(alreadyTakenView)
        alreadyTakenView.clipsToBounds = true
        alreadyTakenView.fillInSuperview()
        alreadyTakenView.isHidden = true
        
        addSubview(selectionView)
        selectionView.fillInSuperview()
        selectionView.clipsToBounds = true
        selectionView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        alreadyTakenView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width / 2
    }
    
    func configure(forColor color: Color) {
        backgroundColor = color.uiColor
        if color.taken {
            alreadyTakenView.isHidden = false
        }
    }
}
