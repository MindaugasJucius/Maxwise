import UIKit

extension CALayer {
    func applyShadow(color: UIColor) {
        shadowRadius = 5
        shadowOffset = CGSize.init(width: 3, height: 2)
        shadowColor = color.cgColor
        shadowOpacity = 0.3
        masksToBounds = false
    }
    
    func applyBorder() {
        borderWidth = 1
        cornerRadius = 6
    }
}
