import RealmSwift
import Foundation
import UIKit

public class ExpenseCategory: Object {
    
    private static let defaultEmojiValue = "💸"
    
    @objc public dynamic var id: String! = ""
    @objc public dynamic var title = ""
    @objc public dynamic var emojiValue = ExpenseCategory.defaultEmojiValue
    @objc public dynamic var color: Color?
    @objc public dynamic var creationDate = Date()
    
    public let expenses = LinkingObjects(fromType: ExpenseEntry.self, property: "category")
        
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func isEmpty() -> Bool {
        return id.isEmpty
    }
}
