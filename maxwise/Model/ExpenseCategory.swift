import RealmSwift

class ExpenseCategory: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var creationDate = Date()
    
    let expenses = LinkingObjects(fromType: ExpenseEntry.self, property: "category")
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
