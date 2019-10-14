import Foundation
import ExpenseKit
import UIKit

class CategoriesListViewModel {

    private let expenseCategoryModelController = ExpenseCategoryModelController()
    private let expenseModelController = ExpenseEntryModelController()

    
    typealias CategoryListSnapshot = NSDiffableDataSourceSnapshot<Date, ExpenseCategoryStatsDTO>

    // For list vc to observe
    var updateToSnapshot: (CategoryListSnapshot) -> () = { _ in }
    
    // When selected section in list VC changes
    let listSectionSelectionChanged: (Int) -> ()
    
    init(listSectionSelectionChanged: @escaping (Int) -> ()) {
        self.listSectionSelectionChanged = listSectionSelectionChanged
    }
    
    func expenses(for categoryID: String, date: Date) -> [ExpenseEntry] {
        guard let category = expenseCategoryModelController.category(from: categoryID) else {
            return []
        }
        return expenseModelController.filter(expenses: Array(category.expenses), by: date)
    }
    
    func updateList(with dateCategories: [(Date, [ExpenseCategoryStatsDTO])]) {
        var snapshot = CategoryListSnapshot.init()
        dateCategories.forEach { (date, categories) in
            snapshot.appendSections([date])
            snapshot.appendItems(categories, toSection: date)
        }
        updateToSnapshot(snapshot)
    }
}
