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
        collectionView.showsHorizontalScrollIndicator = false
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
