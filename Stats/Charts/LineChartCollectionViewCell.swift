import UIKit
import Charts

class LineChartCollectionViewCell: UICollectionViewCell, ChartCollectionViewCell {

    private lazy var lineChart: LineChartView = {
        let lineChart = LineChartView()
        lineChart.pinchZoomEnabled = false
        lineChart.drawGridBackgroundEnabled = true
        lineChart.gridBackgroundColor = UIColor(named: "background")!
        
        lineChart.drawBordersEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.dragYEnabled = false
        lineChart.dragXEnabled = true
        lineChart.legend.enabled = false
        
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelCount = 4 // 4 weeks
        lineChart.xAxis.decimals = 0
        
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        lineChart.leftAxis.drawLabelsEnabled = false
        
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false

        lineChart.minOffset = 20
        lineChart.extraTopOffset = 20
        lineChart.clipsToBounds = false
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
