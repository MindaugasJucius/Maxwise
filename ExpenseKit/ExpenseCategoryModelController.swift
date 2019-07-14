import Foundation
import RealmSwift
import UIKit

public class ExpenseCategoryModelController {
    
    private let defaultCategoriesCreatedKey = "defaultCategoriesCreated"
    
    public func addDefaultCategoriesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: defaultCategoriesCreatedKey) else {
            return
        }
        
        let defaultCategoryProperties: [(String, UIColor)] = [("Food", .tealBlue),
                                                              ("Entertainment", .pink),
                                                              ("Eating Out", .orange),
                                                              ("Sport", .blue)]
        defaultCategoryProperties.map { properties in
            let category = ExpenseCategory()
            category.title = properties.0
            category.colorHexValue = properties.1.hexString
            category.id = NSUUID.init().uuidString
            return category
        }.forEach {
            store(category: $0)
        }
        UserDefaults.standard.set(true, forKey: defaultCategoriesCreatedKey)
    }

    public init() {
        
    }
    
    public func storedCategories() -> [ExpenseCategory] {
        guard let realm = try? Realm() else {
            return []
        }
        return Array(realm.objects(ExpenseCategory.self))
    }
    
    public func store(category: ExpenseCategory) {
        guard let realm = try? Realm() else {
            return
        }
        try? realm.write {
            realm.add(category)
        }
    }
}
