import RealmSwift
import Foundation

class User: Object {

    @objc dynamic var id: String! = ""
    @objc dynamic var name = ""
    let entries = List<ExpenseEntry>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
