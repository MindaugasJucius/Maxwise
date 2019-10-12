import UIKit

extension UICollectionView {
    func itemAtCenter() -> IndexPath? {
        let point = CGPoint.init(x: bounds.midX,
                                 y: bounds.midY)
        return indexPathForItem(at: point)
    }
}

