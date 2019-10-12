import UIKit

extension UICollectionView {
    func itemAtCenter() -> IndexPath? {
        let point = CGPoint.init(x: bounds.midX,
                                 y: 0)
        return indexPathForItem(at: point)
    }
}

