import RealmSwift

class ExpenseEntry: Object {

    @objc dynamic var id = ""
    @objc dynamic var amount: Double = 0
    @objc dynamic var imageData: Data?
        
    override static func primaryKey() -> String? {
        return "id"
    }
}
