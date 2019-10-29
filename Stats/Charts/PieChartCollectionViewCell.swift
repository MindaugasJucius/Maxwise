import UIKit
import Charts

class PieChartCollectionViewCell: UICollectionViewCell, ChartCollectionViewCell {

    private let selectionFeedback = UISelectionFeedbackGenerator()

    var selectedToHightlightCategory: ((String) -> ())?
    
    private lazy var pieChartView: PieChartView = {
        let pieChart = PieChartView()
        pieChart.noDataText = "Add expenses to see pie chart"
        pieChart.noDataFont = .systemFont(ofSize: 20)
        pieChart.noDataTextColor = .secondaryLabel
        pieChart.holeColor = UIColor.init(named: "background")
        pieChart.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.usePercentValuesEnabled = true
        pieChart.legend.enabled = false
        pieChart.delegate = self
        return pieChart
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pieChartView)
        pieChartView.fillInSuperview()
    }

    func removeSelection() {
        pieChartView.highlightValue(nil, callDelegate: false)
    }
    
    func update(data: ChartData) {
        removeSelection()
        pieChartView.data = data
        pieChartView.animate(yAxisDuration: 0.3, easingOption: .easeInSine)
    }
    
    func clearData() {
        pieChartView.data = nil
    }
}

extension PieChartCollectionViewCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let formattedEntry = entry.data as? FormattedPieChartEntry else {
            return
        }
        selectionFeedback.selectionChanged()
        selectedToHightlightCategory?(formattedEntry.categoryID)
    }
    
}

