import UIKit

class MonthSelectionView: UIView {

    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                        heightDimension: .fractionalWidth(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(35))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 10
            return section
        }
        
        let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfiguration.scrollDirection = .vertical
        layout.configuration = layoutConfiguration
        return layout
    }()
    
    private let dateFormatter = DateFormatter()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.fillInSuperview()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: UICollectionViewCell.nibName)
        collectionView.dataSource = self
        collectionView.allowsSelection = true
    }
    
}

extension MonthSelectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateFormatter.monthSymbols.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.nibName,
                                                      for: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
    
}
