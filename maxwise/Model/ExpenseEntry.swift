import RealmSwift

class ExpenseEntry: Object {

    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var amount: Double = 0
    @objc dynamic var imageData: Data?
    @objc dynamic var creationDate = Date()
    @objc dynamic var place: NearbyPlace?
    @objc dynamic var category: ExpenseCategory?
    let owners = LinkingObjects(fromType: User.self, property: "entries")
        
    override static func primaryKey() -> String? {
        return "id"
    }
}
