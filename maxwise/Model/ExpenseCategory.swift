import RealmSwift

class ExpenseCategory: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var colorHexValue: String = ""
    @objc dynamic var creationDate = Date()
    
    let expenses = LinkingObjects(fromType: ExpenseEntry.self, property: "category")
    
    var color: UIColor? {
        return UIColor(hex: colorHexValue)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
