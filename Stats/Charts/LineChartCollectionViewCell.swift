import UIKit
import Charts

class LineChartCollectionViewCell: UICollectionViewCell, ChartCollectionViewCell {

    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    private let xAxisLabelCount = 4 // number of weeks in month
    
    var selectedToFilterByDate: ((Date) -> ())?
    var nothingSelected: (() -> ())?
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        formatter.alwaysShowsDecimalSeparator = false
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    private lazy var lineChart: LineChartView = {
        let lineChart = LineChartView()
        
        lineChart.noDataText = "Add expenses to see line chart"
        lineChart.noDataFont = .systemFont(ofSize: 20)
        lineChart.noDataTextColor = .secondaryLabel
        
        lineChart.pinchZoomEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.scaleYEnabled = false
        lineChart.drawGridBackgroundEnabled = true
        lineChart.gridBackgroundColor = UIColor(named: "background")!
        
        lineChart.drawBordersEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.dragYEnabled = false
        lineChart.dragXEnabled = true
        lineChart.legend.enabled = false

        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.decimals = 0
        lineChart.xAxis.labelFont = .systemFont(ofSize: 10, weight: .regular)
        lineChart.xAxis.labelTextColor = .quaternaryLabel

        lineChart.leftAxis.drawGridLinesEnabled = true
        lineChart.leftAxis.gridColor = .quaternaryLabel
        lineChart.leftAxis.gridLineDashLengths = [3,6]
        lineChart.leftAxis.gridLineCap = .round
        
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.leftAxis.labelFont = .systemFont(ofSize: 10, weight: .regular)
        lineChart.leftAxis.labelTextColor = .quaternaryLabel
        lineChart.leftAxis.drawLabelsEnabled = true
        lineChart.leftAxis.labelPosition = .outsideChart

        lineChart.leftAxis.valueFormatter = self
        lineChart.leftAxis.setLabelCount(3, force: true)
        
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false

        lineChart.minOffset = 20
        lineChart.extraTopOffset = 20
        lineChart.clipDataToContentEnabled = false
        lineChart.layer.masksToBounds = false
        lineChart.delegate = self
        
        return lineChart
    }()
    
    private var timer: Timer?
        
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true {
            lineChart.marker = createMarker()
        }
        
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineChart)
        lineChart.marker = createMarker()
        lineChart.fillInSuperview()
    }
    
    func removeSelection() {
        lineChart.highlightValue(nil, callDelegate: false)
    }

    func update(data: ChartData) {
        if data.entryCount < xAxisLabelCount {
            lineChart.xAxis.setLabelCount(data.entryCount, force: true)
        } else {
            lineChart.xAxis.setLabelCount(xAxisLabelCount, force: true)
        }
        nothingSelected?()
        lineChart.leftAxis.axisMaximum = data.getYMax() * 1.25
        lineChart.leftAxis.axisMinimum = 0
        lineChart.animate(yAxisDuration: 0.3, easingOption: .easeInOutQuad)
        lineChart.data = data
    }

    private func createMarker() -> LineChartMarkerView? {
        let marker = LineChartMarkerView.viewFromXib()
        marker?.chartView = lineChart
        return marker
    }
    
}

extension LineChartCollectionViewCell: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let axisValue = NSNumber(value: round(value))
        guard let formattedAmount = currencyFormatter.string(from: axisValue) else {
            return ""
        }
        return formattedAmount
    }
    
}

extension LineChartCollectionViewCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let formattedEntry = entry.data as? FormattedLineChartEntry else {
            return
        }
        selectionFeedback.selectionChanged()
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.25,
            repeats: false,
            block: { [weak self] _ in
                self?.selectedToFilterByDate?(formattedEntry.fullEntryDate)
            }
        )
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        nothingSelected?()
    }
    
}
