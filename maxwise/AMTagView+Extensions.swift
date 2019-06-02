import AMTagListView

extension AMTagView {
    
    var categoryID: String? {
        get {
            return userInfo["id"] as? String
        }
        set {
            userInfo = ["id": newValue as Any]
        }
    }
    
    func applySelectedStyle() {
        tagColor = .gray
        innerTagColor = .gray
    }
    
    func applyDeselectedStyle() {
        tagColor = .lightGray
        innerTagColor = .lightGray
    }
}
