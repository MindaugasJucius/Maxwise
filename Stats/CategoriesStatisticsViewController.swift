import UIKit
import Charts

class CategoriesStatisticsViewController: UIViewController {

    @IBOutlet private weak var pieChartContainer: UIView!
    @IBOutlet private weak var dateRangeSelectionView: CenteredTextSelectionView!
    @IBOutlet private weak var categoriesListContainer: UIView!

    private lazy var categoriesListViewController = CategoriesListViewController()
    
    private let viewModel = CategoriesStatisticsViewModel()
    
    private lazy var pieChartView: PieChartView = {
        let pieChart = PieChartView()
        pieChart.noDataText = "Add expenses to see chart"
        pieChart.noDataFont = .systemFont(ofSize: 20)
        pieChart.noDataTextColor = .secondaryLabel
        pieChart.holeColor = UIColor.init(named: "background")
        pieChart.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.enabled = false
        return pieChart
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        view.backgroundColor = UIColor.init(named: "background")
        pieChartContainer.addSubview(pieChartView)
        pieChartView.fillInSuperview()
  
        addChild(categoriesListViewController)
        categoriesListContainer.addSubview(        categoriesListViewController.view)
        categoriesListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        categoriesListViewController.view.fillInSuperview()

        
        viewModel.shouldUpdateSelection = { [weak self] indexToSelect in
            self?.dateRangeSelectionView.selectItem(at: indexToSelect)
        }
        
        viewModel.categoriesForSelection = { [weak self] data in
            self?.pieChartView.animate(yAxisDuration: 0.3, easingOption: .easeInOutQuad)
            self?.pieChartView.data = data.chartData
        }
        
        viewModel.observeDateRangeSelectionRepresentations { [weak self] representations in
            self?.dateRangeSelectionView.items = representations
        }
        
        dateRangeSelectionView.hasChangedSelectionToItemAtIndex = { [weak self] index in
            self?.viewModel.selected(index: index)
        }
    }
    
}
