import UIKit
import UPCarouselFlowLayout

class MonthSelectionView: UIView {

//    private lazy var layout: UICollectionViewLayout = {
//        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
//            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
//                                                  heightDimension: .fractionalHeight(1))
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(150),
//                                                   heightDimension: .absolute(45))
//
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                           subitem: item,
//                                                           count: 1)
//
//            let section = NSCollectionLayoutSection(group: group)
//            section.orthogonalScrollingBehavior = .groupPagingCentered
//            section.interGroupSpacing = 0
//            return section
//        }
//
//        let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
//        layoutConfiguration.scrollDirection = .vertical
//        layout.configuration = layoutConfiguration
//        return layout
//    }()
        
    lazy var layout: UPCarouselFlowLayout = {
        let layout = UPCarouselFlowLayout()
        layout.itemSize = .init(width: 150, height: 45)
        layout.scrollDirection = .horizontal
        layout.sideItemAlpha = 1
        layout.sideItemScale = 0.8
        return layout
    }()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private var childSubviewContentOffsetObservation: NSKeyValueObservation?
    
    private var previousSelectedIndexPath: IndexPath?
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.performHackityHack()
            }
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
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func performHackityHack() {
        let scrollViews = collectionView.subviews.filter { $0 is UIScrollView }
        let scrollViewWithCells = scrollViews.filter { $0.subviews.first is UICollectionViewCell }
        guard let scrollView = scrollViewWithCells.first as? UIScrollView else {
            print("No hak :(")
            return
        }

        let halfViewWidth = frame.width / 2
        childSubviewContentOffsetObservation = scrollView.observe(\.contentOffset) { [weak self] (scrollView, change) in
            guard let self = self else {
                return
            }
            let offset = CGPoint.init(x: scrollView.contentOffset.x + halfViewWidth,
                                      y: scrollView.contentOffset.y)
            print(self.collectionView.indexPathForItem(at: offset))
        }
    }
    
    private func itemAtCenter() -> IndexPath? {
        let point = CGPoint.init(x: collectionView.bounds.midX,
                                 y: collectionView.bounds.midY)
        return collectionView.indexPathForItem(at: point)
    }
    
}

extension MonthSelectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != previousSelectedIndexPath?.row else {
            return
        }
        previousSelectedIndexPath = indexPath
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
        selectedItemAtIndex?(indexPath.row)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let item = itemAtCenter(),
            let currentlySelectedItem = collectionView.indexPathsForSelectedItems?.first,
            item.row != currentlySelectedItem.row else {
            return
        }
        previousSelectedIndexPath = item
        collectionView.selectItem(at: item,
                                  animated: false,
                                  scrollPosition: .centeredHorizontally)
        selectedItemAtIndex?(item.row)
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
