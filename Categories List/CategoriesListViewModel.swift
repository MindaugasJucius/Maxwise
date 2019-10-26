import Foundation
import ExpenseKit
import UIKit

class CategoriesListViewModel {
    
    typealias CategoryListSnapshot = NSDiffableDataSourceSnapshot<Date, ExpenseCategoryStatsDTO>

    // For list vc to observe
    var updateToSnapshot: (CategoryListSnapshot, Int?) -> () = { _, _ in }
    
    // Invoked by View Controller when selected section in list VC changes
    let listSectionSelectionChanged: (Int) -> ()
    
    // Invoked externally to tell the View Controller to scroll to section
    var shouldScrollToSection: ((Int) -> ())?
    
    init(listSectionSelectionChanged: @escaping (Int) -> ()) {
        self.listSectionSelectionChanged = listSectionSelectionChanged
    }
        
    func updateList(with dateCategories: [(Date, [ExpenseCategoryStatsDTO])], changeSelectionToIndex: Int? = nil) {
        var snapshot = CategoryListSnapshot.init()
        dateCategories.forEach { (date, categories) in
            snapshot.appendSections([date])
            snapshot.appendItems(categories, toSection: date)
        }
        updateToSnapshot(snapshot, changeSelectionToIndex)
    }
}
