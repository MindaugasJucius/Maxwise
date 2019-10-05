import UIKit
import UPCarouselFlowLayout

class CenteredTextSelectionView: UIView {
        
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
    var hasChangedSelectionToItemAtIndex: ((Int) -> ())?

    var items: [String] = [] {
        didSet {
            // If reloading and previously there was an item selected, keep selection
            var rowIndexToPreselect: Int?
            if let selectedRow = collectionView.indexPathsForSelectedItems?.first?.row,
                let selectedRowValue = oldValue[safe: selectedRow],
                let indexInNewItems = items.firstIndex(of: selectedRowValue) {
                rowIndexToPreselect = indexInNewItems
            }
            
            self.collectionView.reloadData()
            
            if let rowIndexToPreselect = rowIndexToPreselect {
                selectItem(at: rowIndexToPreselect)
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
    
    func selectItem(at index: Int) {
        collectionView.selectItem(at: .init(row: index, section: 0),
                                  animated: false,
                                  scrollPosition: .centeredHorizontally)
    }
    
    private func itemAtCenter() -> IndexPath? {
        let point = CGPoint.init(x: collectionView.bounds.midX,
                                 y: collectionView.bounds.midY)
        return collectionView.indexPathForItem(at: point)
    }
}

extension CenteredTextSelectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != previousSelectedIndexPath?.row else {
            return
        }
        previousSelectedIndexPath = indexPath
        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
        hasChangedSelectionToItemAtIndex?(indexPath.row)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let item = itemAtCenter(),
            let currentlySelectedItem = collectionView.indexPathsForSelectedItems?.first,
            item.row != currentlySelectedItem.row else {
            return
        }
        previousSelectedIndexPath = item
        selectItem(at: item.row)
        hasChangedSelectionToItemAtIndex?(item.row)
    }

}

extension CenteredTextSelectionView: UICollectionViewDataSource {
    
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
