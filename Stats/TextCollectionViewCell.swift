import UIKit

class TextCollectionViewCell: UICollectionViewCell {

    private let selectedColor = UIColor.label
    private let deselectedColor = UIColor.label.withAlphaComponent(0.5)
    
    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedColor : deselectedColor
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = deselectedColor
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(label)
        label.fillInSuperview()
    }
    
    func configure(text: String) {
        label.text = text
    }

}
