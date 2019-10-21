import UIKit
import Charts

protocol ChartCollectionViewCell: UICollectionViewCell {
    func update(data: ChartData)
}

class CategoriesChartsViewController: UIViewController {

    private var currentlyVisibleChart: ChartViewBase?
    private var chartDatum: [ChartData] = []

    private lazy var layout: UICollectionViewCompositionalLayout = {
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection.init(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            return section
        }
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        layout.configuration = configuration
        return layout
    }()
    
    enum Charts: Int, CaseIterable {
        case pie
        case line
        
        var cellType: UICollectionViewCell.Type {
            switch self {
            case .line:
                return LineChartCollectionViewCell.self
            case .pie:
                return PieChartCollectionViewCell.self
            }
        }

        var chartDataType: ChartData.Type {
            switch self {
            case .line:
                return LineChartData.self
            case .pie:
                return PieChartData.self
            }
        }
    }
    
    @IBOutlet weak var chartsCollectionView: UICollectionView!
    
    private let viewModel: CategoriesChartsViewModel
    
    init(viewModel: CategoriesChartsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartsCollectionView.setCollectionViewLayout(layout, animated: false)
        chartsCollectionView.dataSource = self
        chartsCollectionView.backgroundColor = UIColor.init(named: "background")
        
        register(cellType: PieChartCollectionViewCell.self)
        register(cellType: LineChartCollectionViewCell.self)
        
        viewModel.chartDataChanged = { [weak self] chartDatum in
            self?.chartDatum = chartDatum
            self?.chartsCollectionView.reloadData()
        }
    }
    
    private func register(cellType: UICollectionViewCell.Type) {
        let nib = UINib(nibName: cellType.nibName, bundle: nil)
        chartsCollectionView.register(
            nib,
            forCellWithReuseIdentifier: cellType.nibName
        )
    }

}

extension CategoriesChartsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Charts.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let chartType = Charts.init(rawValue: indexPath.row) else {
            return UICollectionViewCell()
        }

        guard let chartCell = collectionView.dequeueReusableCell(withReuseIdentifier: chartType.cellType.nibName,
                                                                 for: indexPath) as? ChartCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let data = chartDatum.filter { data in
            let chartDataType = type(of: data)
            return chartDataType == chartType.chartDataType
        }
        
        guard let matchingData = data.first else {
            return chartCell
        }
        
        chartCell.update(data: matchingData)
        
        return chartCell
    }
    
}
