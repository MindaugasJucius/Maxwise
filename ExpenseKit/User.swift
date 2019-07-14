import RealmSwift
import Foundation

public class User: Object {

    @objc public dynamic var id: String! = ""
    @objc public dynamic var name = ""
    public let entries = List<ExpenseEntry>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
