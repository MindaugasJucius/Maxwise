import RealmSwift
import Foundation

public class ExpenseEntry: Object {

    @objc public dynamic var id: String! = ""
    @objc public dynamic var title = ""
    @objc public dynamic var amount: Double = 0
    @objc public dynamic var imageData: Data?
    @objc public dynamic var creationDate = Date()
    @objc public dynamic var place: NearbyPlace?
    @objc public dynamic var category: ExpenseCategory?
    public let owners = LinkingObjects(fromType: User.self, property: "entries")
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
