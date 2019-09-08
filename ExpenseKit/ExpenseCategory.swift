import RealmSwift
import Foundation
import UIKit

public class ExpenseCategory: Object {
    
    private static let defaultEmojiValue = "💸"
    
    @objc public dynamic var id: String! = ""
    @objc public dynamic var title = ""
    @objc public dynamic var emojiValue = ExpenseCategory.defaultEmojiValue
    @objc public dynamic var colorHexValue: String = ""
    @objc public dynamic var creationDate = Date()
    
    public let expenses = LinkingObjects(fromType: ExpenseEntry.self, property: "category")
    
    public var color: UIColor? {
        return UIColor(hex: colorHexValue)
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func isEmpty() -> Bool {
        return emojiValue == ExpenseCategory.defaultEmojiValue
            && title.isEmpty
            && colorHexValue.isEmpty
    }
}
