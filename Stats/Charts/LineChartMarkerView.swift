import Charts
import UIKit

class LineChartMarkerView: MarkerView {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountLabelWidthConstraint: NSLayoutConstraint!
    
    private let yOffset: CGFloat = 10
    
    override var offset: CGPoint {
        get {
            return CGPoint.init(x: -(frame.width / 2),
                                y: -frame.height - yOffset)
        }
        set {
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        amountLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        amountLabel.textColor = .label
        backgroundColor = .white
        
        let shadowColor = UIColor.black.withAlphaComponent(0.4)
        layer.applyShadow(color: shadowColor)
        layer.applyBorder()
        layer.borderColor = UIColor.clear.cgColor
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override class func viewFromXib(in bundle: Bundle = .main) -> LineChartMarkerView? {
        return bundle.loadNibNamed(nibName,
                                   owner: nil,
                                   options: nil)?[0] as? LineChartMarkerView
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        amountLabelWidthConstraint.constant = widthForAmountLabel()
        layoutIfNeeded()
    }
    
    func widthForAmountLabel() -> CGFloat {
        guard let text = amountLabel.text as NSString? else {
            return .zero
        }
        
        return text.size(
            withAttributes: [.font : amountLabel.font as Any]
        ).width
    }
    
}
