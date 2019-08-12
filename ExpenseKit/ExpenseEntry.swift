import RealmSwift
import Foundation



public struct ExpenseDTO {

    public enum SharePercentage {
        case full
        case half
        case custom(Double)
        
        public var uiRepresentation: String {
            switch self {
            case .custom(let customPercentage):
                return "\(customPercentage)%"
            case .full:
                return "100%"
            case .half:
                return "50%"
            }
        }
        
        var databaseRepresentation: Double {
            switch self {
            case .custom(let amount):
                return amount
            case .full:
                return 100
            case .half:
                return 50
            }
        }
        
    }
    
    public let category: ExpenseCategory
    public let user: User
    public let place: NearbyPlace?
    public let amount: Double
    public let shareAmount: SharePercentage

    public init(category: ExpenseCategory,
         user: User,
         place: NearbyPlace?,
         amount: Double,
         shareAmount: SharePercentage) {
        self.category = category
        self.user = user
        self.place = place
        self.amount = amount
        self.shareAmount = shareAmount
    }
}

public class ExpenseEntry: Object {

    @objc public dynamic var id: String! = ""
    @objc public dynamic var title = ""
    @objc public dynamic var amount: Double = 0
    @objc public dynamic var sharePercentage: Double = 0
    @objc public dynamic var imageData: Data?
    @objc public dynamic var creationDate = Date()
    @objc public dynamic var place: NearbyPlace?
    @objc public dynamic var category: ExpenseCategory?
    public let owners = LinkingObjects(fromType: User.self, property: "entries")
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
