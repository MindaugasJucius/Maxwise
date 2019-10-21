import UIKit
import Charts

class LineChartCollectionViewCell: UICollectionViewCell, ChartCollectionViewCell {

    private lazy var lineChart: LineChartView = {
        let lineChart = LineChartView()
        lineChart.pinchZoomEnabled = false
        lineChart.drawGridBackgroundEnabled = false
        lineChart.drawBordersEnabled = false
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
