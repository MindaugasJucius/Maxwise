import UIKit

extension UIColor {
    static var tintColor: UIColor? {
        get {
            return UIApplication.shared.windows.first?.rootViewController?.view.tintColor
        }
    }
}
