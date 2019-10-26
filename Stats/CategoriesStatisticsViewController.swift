import UIKit
import Charts

class CategoriesStatisticsViewController: UIViewController {

    @IBOutlet private weak var chartsControllerContainer: UIView!
    @IBOutlet private weak var dateRangeSelectionView: CenteredTextSelectionView!
    @IBOutlet private weak var categoriesListContainer: UIView!
    
    private let categoriesListViewController: CategoriesListViewController
    
    private lazy var chartsViewController = CategoriesChartsViewController(
        viewModel: viewModel.categoriesChartsViewModel
    )
    
    private let viewModel: CategoriesStatisticsViewModel
        
    init(choseToViewExpensesForCategory: @escaping (ExpenseCategoryStatsDTO, Date) -> (),
         choseToEditCategory: @escaping (String) -> (),
         choseToDeleteCategory: @escaping (String) -> ()) {
        self.viewModel = CategoriesStatisticsViewModel()
        self.categoriesListViewController = CategoriesListViewController(
            viewModel: self.viewModel.categoriesListViewModel,
            choseToViewExpensesForCategory: choseToViewExpensesForCategory,
            choseToEditCategory: choseToEditCategory,
            choseToDeleteCategory: choseToDeleteCategory
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
        view.backgroundColor = UIColor.init(named: "background")

        addChild(chartsViewController)
        chartsControllerContainer.addSubview(chartsViewController.view)
        chartsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        chartsViewController.view.fillInSuperview()

        
        addChild(categoriesListViewController)
        categoriesListContainer.addSubview(categoriesListViewController.view)
        categoriesListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        categoriesListViewController.view.fillInSuperview()

        viewModel.updateDateRangeSelection = { [weak self] indexToSelect in
            self?.dateRangeSelectionView.selectItem(at: indexToSelect)
        }
        
        viewModel.observeDateRangeSelectionRepresentations { [weak self] representations in
            self?.dateRangeSelectionView.items = representations
        }
                
        dateRangeSelectionView.hasChangedSelectionToItemAtIndex = { [weak self] index in
            self?.viewModel.invokeChartDataChange(for: index)
            self?.viewModel.categoriesListViewModel.shouldScrollToSection?(index)
        }
    }
        
}
