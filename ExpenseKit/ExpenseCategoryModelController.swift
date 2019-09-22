import Foundation
import RealmSwift
import Intents
import UIKit

public class ExpenseCategoryModelController {
    
    private let colorModelController = ColorModelController()

    private var expenseCategoryObservationToken: NotificationToken?
    
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
    
    /// Observe changes to expense categories entries.
    /// Since Realm notifications do not take inverse relationships into account we need to observe ExpenseEntry changes
    /// and get ExpenseCategories from them
    /// - Parameter updated: closure called with ExpenseCategories
    public func observeExpenseCategoryChanges(updated: @escaping ([ExpenseCategory]) -> ()) {
        let realm = try? Realm.groupRealm()
        expenseCategoryObservationToken = realm?.objects(ExpenseEntry.self)
            .observe { change in
                switch change {
                case .initial(let value):
                    updated(Array(Set(value.compactMap { $0.category })))
                case .update(let value, deletions: _, insertions: _, modifications: _):
                    updated(Array(Set(value.compactMap { $0.category })))
                default:
                    print("huh")
                }
            }
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
