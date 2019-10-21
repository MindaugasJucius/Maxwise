import UIKit
import Charts

class LineChartCollectionViewCell: UICollectionViewCell, ChartCollectionViewCell {

    private lazy var lineChart: LineChartView = {
        let lineChart = LineChartView()
        lineChart.pinchZoomEnabled = false
        lineChart.drawGridBackgroundEnabled = true
        lineChart.drawBordersEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.dragYEnabled = false
        lineChart.legend.enabled = false
        
        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.drawAxisLineEnabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelCount = 4 // 4 weeks
        lineChart.xAxis.decimals = 0
        
        lineChart.leftAxis.drawGridLinesEnabled = false
        lineChart.leftAxis.drawAxisLineEnabled = false
        
        lineChart.rightAxis.drawAxisLineEnabled = false
        lineChart.rightAxis.drawLabelsEnabled = false
        lineChart.rightAxis.drawGridLinesEnabled = false
        
        lineChart.minOffset = 20
        return lineChart
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineChart)
        lineChart.fillInSuperview()
    }

    func update(data: ChartData) {
        lineChart.data = data
    }
    
}
