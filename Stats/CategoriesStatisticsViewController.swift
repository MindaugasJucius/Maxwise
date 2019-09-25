import UIKit
import Charts

class CategoriesStatisticsViewController: UIViewController {

    @IBOutlet private weak var pieChartContainer: UIView!
    @IBOutlet private weak var monthSelectionView: MonthSelectionView!
    
    
    private let viewModel = CategoriesStatisticsViewModel()
    
    private lazy var pieChartView: PieChartView = {
        let pieChart = PieChartView()
        pieChart.noDataText = "Add expenses to see chart"
        pieChart.noDataFont = .systemFont(ofSize: 20)
        pieChart.noDataTextColor = .secondaryLabel
        pieChart.holeColor = UIColor.init(named: "background")
        pieChart.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChart.drawEntryLabelsEnabled = false
        return pieChart
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        view.backgroundColor = UIColor.init(named: "background")
        pieChartContainer.addSubview(pieChartView)
        pieChartView.fillInSuperview()
        viewModel.observeCategoryTotals { [weak self] data in
            self?.pieChartView.data = data
        }
        // Do any additional setup after loading the view.
    }
    
}
