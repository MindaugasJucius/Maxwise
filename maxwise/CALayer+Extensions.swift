import UIKit

extension CALayer {
    func applyShadow() {
        shadowRadius = 5
        shadowOffset = CGSize.init(width: 3, height: 2)
        shadowColor = UIColor.lightGray.cgColor
        shadowOpacity = 0.3
        masksToBounds = false
    }
    
    func applyBorder() {
        borderWidth = 1
        cornerRadius = 6
        borderColor = UIColor.clear.cgColor
    }
}
