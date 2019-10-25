import UIKit
import Charts

class LineChartCollectionViewCell: UICollectionViewCell, ChartCollectionViewCell {

    private lazy var lineChart: LineChartView = {
        let lineChart = LineChartView()
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
        lineChart.xAxis.yOffset = 0
        
        lineChart.xAxis.drawGridLinesEnabled = true
        lineChart.xAxis.gridColor = .quaternaryLabel
        lineChart.xAxis.gridLineDashLengths = [2,6]
        lineChart.xAxis.gridLineCap = .round
        
        lineChart.xAxis.drawAxisLineEnabled = true
        lineChart.xAxis.axisLineColor = .quaternaryLabel
        lineChart.xAxis.labelPosition = .bottom
        
        lineChart.xAxis.labelCount = 4 // 4 weeks
        lineChart.xAxis.decimals = 0
        lineChart.xAxis.labelFont = .systemFont(ofSize: 10, weight: .regular)
        lineChart.xAxis.labelTextColor = .quaternaryLabel
        
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.leftAxis.drawLabelsEnabled = false
        
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false

        lineChart.minOffset = 20
        lineChart.extraTopOffset = 20
        lineChart.clipDataToContentEnabled = false
        
        return lineChart
    }()
    
    var marker: LineChartMarkerView? {
        let marker = LineChartMarkerView.viewFromXib()
        marker?.chartView = lineChart
        return marker
    }
        
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) == true {
            lineChart.marker = marker
        }
        
        super.traitCollectionDidChange(previousTraitCollection)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        
        lineChart.marker = marker
        
        addSubview(lineChart)
        lineChart.fillInSuperview()
    }

    func update(data: ChartData) {
        lineChart.data = data
    }
    
}
