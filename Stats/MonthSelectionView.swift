import UIKit

class MonthSelectionView: UIView {

    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(150),
                                                   heightDimension: .absolute(45))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: 1)

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.interGroupSpacing = 0
            return section
        }
        
        let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfiguration.scrollDirection = .vertical
        layout.configuration = layoutConfiguration
        return layout
    }()
        
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    var selectedItemAtIndex: ((Int) -> ())?

    var items: [String] = [] {
        didSet {
            // If reloading and previously there was an item selected, keep selection
            let rowIndexToPreselect: Int
            if let selectedRow = collectionView.indexPathsForSelectedItems?.first?.row,
                let selectedRowValue = oldValue[safe: selectedRow],
                let indexInNewItems = items.firstIndex(of: selectedRowValue) {
                rowIndexToPreselect = indexInNewItems
            } else {
                rowIndexToPreselect = items.count - 1
            }
            
            self.collectionView.reloadData()
            self.collectionView.selectItem(at: .init(row: rowIndexToPreselect, section: 0),
                                           animated: false,
                                           scrollPosition: .centeredHorizontally)
        }
    }
    
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
        let nib = UINib.init(nibName: TextCollectionViewCell.nibName, bundle: nil)
        collectionView.register(nib,
                                forCellWithReuseIdentifier: TextCollectionViewCell.nibName)
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }
    
}

extension MonthSelectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
        selectedItemAtIndex?(indexPath.row)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDragging")
    }
}

extension MonthSelectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCollectionViewCell.nibName,
                                                      for: indexPath)
        guard let textCell = cell as? TextCollectionViewCell else {
            return cell
        }
        textCell.configure(text: items[indexPath.row])
        return textCell
    }
    
}
