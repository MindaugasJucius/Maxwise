import Foundation
import ExpenseKit
import UIKit

class CategoriesListViewModel {
    
    typealias CategoryListSnapshot = NSDiffableDataSourceSnapshot<Date, ExpenseCategoryStatsDTO>

    var currentSnapshot: CategoriesListViewModel.CategoryListSnapshot?
    
    // For list vc to observe
    var updateToSnapshot: (CategoryListSnapshot, Int?) -> () = { _, _ in }
    
    // Invoked by View Controller when selected section in list VC changes
    let listSectionSelectionChanged: (Int) -> ()
    
    // Invoked externally to tell the View Controller to scroll to section
    var shouldScrollToSection: ((Int) -> ())?
    
    // Invoked externally to tell the View Controller to highligh a cell
    var shouldHighlightCell: ((ExpenseCategoryStatsDTO) -> ())?
    
    init(listSectionSelectionChanged: @escaping (Int) -> ()) {
        self.listSectionSelectionChanged = listSectionSelectionChanged
    }
    
    func highlight(currentSelectedSection: Int, categoryID: String) {
        guard var snapshot = currentSnapshot else {
            return
        }

        let sectionToHighlight = snapshot.sectionIdentifiers[currentSelectedSection]
        let identifier = snapshot.itemIdentifiers(inSection: sectionToHighlight).filter { $0.categoryID == categoryID }.first
    
        guard let identifierToHighlight = identifier else {
            return
        }
        
        shouldHighlightCell?(identifierToHighlight)
    }
        
    func reload(currentSelectedSection: Int, with newItems: [ExpenseCategoryStatsDTO]) {
        guard var snapshot = currentSnapshot else {
            return
        }
        
        let sectionToReload = snapshot.sectionIdentifiers[currentSelectedSection]
        let items = snapshot.itemIdentifiers(inSection: sectionToReload)
        snapshot.deleteItems(items)
        snapshot.appendItems(newItems, toSection: sectionToReload)

        updateToSnapshot(snapshot, nil)
    }
    
    func updateList(with dateCategories: [(Date, [ExpenseCategoryStatsDTO])], changeSelectionToIndex: Int? = nil) {
        var snapshot = CategoryListSnapshot.init()
        dateCategories.forEach { (date, categories) in
            snapshot.appendSections([date])
            snapshot.appendItems(categories, toSection: date)
        }
        updateToSnapshot(snapshot, changeSelectionToIndex)
    
        currentSnapshot = snapshot
    }
}
