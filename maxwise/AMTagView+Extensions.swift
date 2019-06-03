import AMTagListView

extension AMTagView {
    
    var categoryID: String? {
        get {
            return userInfo["id"] as? String
        }
        set {
            userInfo["id"] = newValue as Any
        }
    }
    
    var color: UIColor? {
        get {
            return userInfo["color"] as? UIColor
        }
        set {
            userInfo["color"] = newValue as Any
        }
    }
    
    func applySelectedStyle(color: UIColor) {
        tagColor = color
        innerTagColor = color
    }
    
    func applyDeselectedStyle(color: UIColor) {
        let transparentColor = color.withAlphaComponent(0.5)
        tagColor = transparentColor
        innerTagColor = transparentColor
    }
}
