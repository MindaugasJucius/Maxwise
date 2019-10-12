import Foundation
import UIKit

class CategoriesListViewModel {
    
    typealias CategoryListSnapshot = NSDiffableDataSourceSnapshot<Date, ExpenseCategoryStatsDTO>

    // For list vc to observe
    var updateToSnapshot: (CategoryListSnapshot) -> () = { _ in }
    
    // When selected section in list VC changes
    let listSelectionChanged: (Int) -> ()
    
    init(listSelectionChanged: @escaping (Int) -> ()) {
        self.listSelectionChanged = listSelectionChanged
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
