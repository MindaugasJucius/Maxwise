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

        func mapCategory() -> ExpenseCategory {
            let category = ExpenseCategory()
            category.title = title
            category.emojiValue = emojiValue
            category.color = color
            return category
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
                let mappedCategory = properties.mapCategory()
                if mappedCategory.title == defaultPreselectedCategoryName {
                    UserDefaults.standard.set(mappedCategory.id, forKey: ExpenseCategoryModelController.preselectedCategoryKey)
                }
                return mappedCategory
            }.forEach {
                persist(expenseCategory: $0)
            }
            
            UserDefaults.standard.set(true, forKey: defaultCategoriesCreatedKey)
        }
    }
        
    public func storedCategories() -> [ExpenseCategory] {
        guard let realm = try? Realm.groupRealm() else {
            return []
        }
        return Array(realm.objects(ExpenseCategory.self))
    }
    
    /// Observe changes to expense categories entries.
    /// Since Realm notifications do not take inverse relationships (LinkingObjects) into account we need to observe ExpenseEntry changes
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
    
    public func category(from id: String) -> ExpenseCategory? {
        let realm = try? Realm.groupRealm()
        return realm?.objects(ExpenseCategory.self).filter("id == %@", id).first
    }
    
    public func edit(expenseCategory: ExpenseCategory, newValues properties: Category) {
        guard let realm = try? Realm.groupRealm() else {
            return
        }
        try? realm.write {
            expenseCategory.emojiValue = properties.emojiValue
            expenseCategory.title = properties.title

            // Free old selected color
            expenseCategory.color?.taken = false
            
            expenseCategory.color = properties.color
            expenseCategory.color?.taken = true

            realm.add(expenseCategory, update: .all)
        }
    }
    
    public func persist(category: Category) {
        let mapped = category.mapCategory()
        persist(expenseCategory: mapped)
    }

    private func persist(expenseCategory: ExpenseCategory) {
        guard let realm = try? Realm.groupRealm() else {
            return
        }
        try? realm.write {
            expenseCategory.id = NSUUID.init().uuidString
            expenseCategory.color?.taken = true
            realm.add(expenseCategory, update: .all)
        }
    }
}
