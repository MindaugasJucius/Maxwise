import UIKit
import Charts

class CategoriesStatisticsViewController: UIViewController {

    @IBOutlet private weak var pieChartContainer: UIView!
    @IBOutlet private weak var dateRangeSelectionView: CenteredTextSelectionView!
    @IBOutlet private weak var categoriesListContainer: UIView!

    private lazy var categoriesListViewController = CategoriesListViewController.init(
        viewModel: viewModel.categoriesListViewModel
    )
    
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
        categoriesListContainer.addSubview(categoriesListViewController.view)
        categoriesListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        categoriesListViewController.view.fillInSuperview()

        
        viewModel.shouldUpdateSelection = { [weak self] indexToSelect in
            self?.dateRangeSelectionView.selectItem(at: indexToSelect)
        }
        
        viewModel.observeDateRangeSelectionRepresentations { [weak self] representations in
            self?.dateRangeSelectionView.items = representations
        }
                
        viewModel.selectedCategoryChartData = { [weak self] data in
            self?.animateChart(to: data)
        }
        
        dateRangeSelectionView.hasChangedSelectionToItemAtIndex = { [weak self] index in
            guard let chartData = self?.viewModel.chartDataForSelectedCategory(at: index) else {
                return
            }
            self?.animateChart(to: chartData)
            self?.categoriesListViewController.scroll(to: index)
        }
    }
    
    func animateChart(to data: PieChartData) {
        pieChartView.animate(yAxisDuration: 0.3, easingOption: .easeInOutQuad)
        pieChartView.data = data
    }
    
}
