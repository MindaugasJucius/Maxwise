import RealmSwift

class User: Object {

    @objc dynamic var id = ""
    @objc dynamic var name = ""
    let entries = List<ExpenseEntry>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
