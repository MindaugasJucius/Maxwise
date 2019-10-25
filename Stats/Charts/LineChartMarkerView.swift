import Charts
import UIKit

class LineChartMarkerView: MarkerView {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!

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
        
        let accentColor = UIColor.systemGray.withAlphaComponent(0.2)
        
        separatorView.backgroundColor = accentColor
        layer.applyShadow(color: accentColor)
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
        print(highlight.dataIndex)
//        chartView?.data?.dataSets.first?.entryCount
        guard let formattedEntry = entry.data as? FormattedLineChartEntry else {
            return
        }
        dateLabel.text = formattedEntry.monthDayRepresentation
        amountLabel.text = formattedEntry.totalAmountSpent

        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
