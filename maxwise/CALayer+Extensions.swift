import UIKit

extension CALayer {
    func applyShadow(color: UIColor) {
        shadowRadius = 5
        shadowOffset = CGSize.init(width: 0, height: 2)
        shadowColor = color.cgColor
        shadowOpacity = 0.5
        masksToBounds = false
    }
    
    func applyBorder() {
        cornerCurve = .continuous
        borderWidth = 1
        cornerRadius = 6
    }
}
