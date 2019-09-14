import Foundation
import RealmSwift
import Intents
import UIKit

public class ExpenseCategoryModelController {
    
    private let colorModelController = ColorModelController()
    
    private let defaultCategoriesCreatedKey = "defaultCategoriesCreated"
    private let defaultPreselectedCategoryName = "Food"
    public static let preselectedCategoryKey = "preselectedCategoryKey"

    public struct Category {
        let title: String
        let emojiValue: String
        let color: Color

        public init(title: String,
                    emojiValue: String,
                    color: Color) {
            self.title = title
            self.emojiValue = emojiValue
            self.color = color
        }
    }
    
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
                    return Category(title: maybeCategory.0, emojiValue: maybeCategory.1, color: color)
                }
                return nil
            }
            
            nonNilCategories.map { properties in
                let mappedCategory = mapCategory(from: properties)
                if mappedCategory.title == defaultPreselectedCategoryName {
                    UserDefaults.standard.set(mappedCategory.id, forKey: ExpenseCategoryModelController.preselectedCategoryKey)
                }
                return mappedCategory
            }.forEach {
                persist(category: $0)
            }
            
            UserDefaults.standard.set(true, forKey: defaultCategoriesCreatedKey)
        }
    }
    
    private func mapCategory(from properties: Category) -> ExpenseCategory {
        let category = ExpenseCategory()
        category.title = properties.title
        category.emojiValue = properties.emojiValue
        category.color = properties.color
        category.id = NSUUID.init().uuidString
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
    
    public func store(category properties: Category) {
        let mapped = mapCategory(from: properties)
        persist(category: mapped)
    }
    
    private func persist(category: ExpenseCategory) {
        guard let realm = try? Realm.groupRealm() else {
            return
        }
        try? realm.write {
            category.color?.taken = true
            realm.add(category)
        }
    }
}
