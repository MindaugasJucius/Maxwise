import Charts
import UIKit

class LineChartMarkerView: MarkerView {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var xMarkImageView: UIImageView!
    
    private let yOffset: CGFloat = 10
    private let additionalOffsetWhenOutOfBounds: CGFloat = 10

    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        amountLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        amountLabel.textColor = .label
        backgroundColor = .secondarySystemBackground
        
        xMarkImageView.preferredSymbolConfiguration =         UIImage.SymbolConfiguration(weight: .medium)
        xMarkImageView.tintColor = .secondaryLabel
        
        let shadowColor = UIColor.systemGray.withAlphaComponent(0.3)
        
        separatorView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.1)
        layer.applyShadow(color: shadowColor)
        layer.applyBorder()
        layer.borderColor = UIColor.clear.cgColor
        layer.masksToBounds = false
        
        translatesAutoresizingMaskIntoConstraints = false
    }

    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        guard let chart = chartView else { return self.offset }
        
        var offset = self.offset
        
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
        if point.x + offset.x < 0.0  // jei su dabartiniu offsetu < chart width
        {
            offset.x = -point.x + additionalOffsetWhenOutOfBounds
        }
        else if point.x + width + offset.x > chart.bounds.size.width // jei su dabartiniu offsetu > chart width
        {
            offset.x = chart.bounds.size.width - point.x - width - additionalOffsetWhenOutOfBounds
        }
        
        if point.y + offset.y < 0
        {
            offset.y = -point.y
        }
        else if point.y + height + offset.y > chart.bounds.size.height // jei su dabartiniu offsetu islenda uz y boundu
        {
            offset.y = chart.bounds.size.height - point.y - height
        }
        
        return offset
    }
    
    override class func viewFromXib(in bundle: Bundle = .main) -> LineChartMarkerView? {
        return bundle.loadNibNamed(nibName,
                                   owner: nil,
                                   options: nil)?[0] as? LineChartMarkerView
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        guard let formattedEntry = entry.data as? FormattedLineChartEntry else {
            return
        }

        dateLabel.text = formattedEntry.monthDayRepresentation
        amountLabel.text = formattedEntry.totalAmountSpent

        setNeedsLayout()
        layoutIfNeeded()

        offset = CGPoint(
            x: -(frame.width / 2),
            y: -frame.height - yOffset
        )
    }
    
}
