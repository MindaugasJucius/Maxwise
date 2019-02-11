import RealmSwift

class ExpenseEntry: Object {

    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var amount: Double = 0
    @objc dynamic var imageData: Data?
    @objc dynamic var creationDate = Date()
        
    override static func primaryKey() -> String? {
        return "id"
    }
}