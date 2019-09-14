import Foundation
import RealmSwift
import Intents
import UIKit

public class ExpenseCategoryModelController {
    
    private let colorModelController = ColorModelController()
    
    private let defaultCategoriesCreatedKey = "defaultCategoriesCreated"
    private let defaultPreselectedCategoryName = "Food"
    public static let preselectedCategoryKey = "preselectedCategoryKey"

    typealias Category = (String, String, Color)
    
    public init() {
        
    }
    
    public func addDefaultCategoriesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: defaultCategoriesCreatedKey) else {
            return
        }
        
        let defaultCategoryColors: [UIColor] = [
            .tealBlue,
            .pink,
            .flatOrange,
            .flatTurquoise,
            .flatEmerald
        ]
        
        colorModelController.saveDefaultCategoryColors(colors: defaultCategoryColors) { colorPairs in
            let defaultCategoryProperties: [(String, String, Color?)] = [(defaultPreselectedCategoryName, "🍛", colorPairs[.tealBlue]),
                                                                         ("Entertainment", "🤸‍♂️", colorPairs[.pink]),
                                                                         ("Eating Out", "🍽", colorPairs[.flatOrange]),
                                                                         ("Sport", "🤾‍♀️", colorPairs[.flatTurquoise]),
                                                                         ("Other", "💸", colorPairs[.flatEmerald])]
            let nonNilCategories = defaultCategoryProperties.compactMap { maybeCategory -> Category? in
                if let color = maybeCategory.2 {
                    return (maybeCategory.0, maybeCategory.1, color)
                }
                return nil
            }
            
            nonNilCategories.map { properties in
                return mapCategory(from: properties)
            }.forEach {
                store(category: $0)
            }
            
            UserDefaults.standard.set(true, forKey: defaultCategoriesCreatedKey)
        }
    }
    
    private func mapCategory(from properties: Category) -> ExpenseCategory {
        let category = ExpenseCategory()
        category.title = properties.0
        category.emojiValue = properties.1
        category.color = properties.2
        category.id = NSUUID.init().uuidString
        
        if category.title == defaultPreselectedCategoryName {
            UserDefaults.standard.set(category.id, forKey: ExpenseCategoryModelController.preselectedCategoryKey)
        }
        
        return category
    }
    
    public func storedCategories() -> [ExpenseCategory] {
        guard let realm = try? Realm.groupRealm() else {
            return []
        }
        return Array(realm.objects(ExpenseCategory.self))
    }
    
    public func category(from intentCategory: IntentCategory) -> ExpenseCategory? {
        return storedCategories().filter { $0.id == intentCategory.identifier }.first
    }
    
    public func store(category: ExpenseCategory) {
        guard let realm = try? Realm.groupRealm() else {
            return
        }
        try? realm.write {
            category.color?.taken = true
            realm.add(category)
        }
    }
}
