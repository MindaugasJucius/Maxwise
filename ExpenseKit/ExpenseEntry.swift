import RealmSwift
import Foundation

public struct ExpenseDTO {

    public enum SharePercentage: RawRepresentable {
        
        public var rawValue: Double {
            switch self {
            case .custom(let double):
                return double
            case .full:
                return 1
            case .half:
                return 0.5
            }
        }
        
        public typealias RawValue = Double
        
        public init?(rawValue: Double) {
            if rawValue == 1 {
                self = .full
            } else if rawValue == 0.5 {
                self = .half
            } else {
                self = .custom(rawValue)
            }
        }
        
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
        
    }
    
    public let title: String
    public let category: ExpenseCategory
    public let user: User
    public let place: NearbyPlace?
    public let amount: Double
    public let shareAmount: SharePercentage

    public init(title: String,
         category: ExpenseCategory,
         user: User,
         place: NearbyPlace?,
         amount: Double,
         shareAmount: SharePercentage) {
        self.category = category
        self.user = user
        self.place = place
        self.amount = amount
        self.shareAmount = shareAmount
        self.title = title
    }
}

public class ExpenseEntry: Object {

    @objc public dynamic var id: String! = ""
    @objc public dynamic var title = ""
    @objc public dynamic var amount: Double = 0
    @objc public dynamic var sharePercentage: Double = 0
    @objc public dynamic var imageData: Data?
    @objc public dynamic var creationDate: Date!
    @objc public dynamic var place: NearbyPlace?
    @objc public dynamic var category: ExpenseCategory?
    
    public let owners = LinkingObjects(fromType: User.self, property: "entries")
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
