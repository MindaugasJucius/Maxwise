import UIKit
import Charts

class CategoriesStatisticsViewController: UIViewController {

    @IBOutlet private weak var pieChartContainer: UIView!
    @IBOutlet private weak var dateRangeSelectionView: CenteredTextSelectionView!
    @IBOutlet private weak var categoriesListContainer: UIView!

    private let choseToDeleteCategory: (String) -> ()
    private let choseToEditCategory: (String) -> ()

    private lazy var categoriesListViewController = CategoriesListViewController.init(
        viewModel: viewModel.categoriesListViewModel,
        choseToEditCategory: choseToEditCategory,
        choseToDeleteCategory: choseToDeleteCategory
    )
    
    private let viewModel = CategoriesStatisticsViewModel()
    
    private lazy var pieChartView: PieChartView = {
        let pieChart = PieChartView()
        pieChart.noDataText = "Add expenses to see analytics"
        pieChart.noDataFont = .systemFont(ofSize: 20)
        pieChart.noDataTextColor = .secondaryLabel
        pieChart.holeColor = UIColor.init(named: "background")
        pieChart.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.enabled = false
        return pieChart
    }()
    
    init(choseToEditCategory: @escaping (String) -> (),
         choseToDeleteCategory: @escaping (String) -> ()) {
        self.choseToDeleteCategory = choseToDeleteCategory
        self.choseToEditCategory = choseToEditCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
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
