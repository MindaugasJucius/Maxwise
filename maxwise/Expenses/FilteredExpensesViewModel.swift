import Foundation
import ExpenseKit

class FilteredExpensesViewModel: ExpensesViewModel {
    
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    private let expenseModelController = ExpenseEntryModelController()
    
    let expenseCategoryStatsDTO: ExpenseCategoryStatsDTO

    var categoryTitleChanged: ((String) -> ())?
    
    private var changeOccured: ((GroupedExpenses) -> Void)?
    
    init(expenseCategoryStatsDTO: ExpenseCategoryStatsDTO) {
        self.expenseCategoryStatsDTO = expenseCategoryStatsDTO
        super.init()
        observeCategoryChanges()
    }
    
    override func observeExpenseEntries(changeOccured: @escaping (GroupedExpenses) -> Void) {
        let filterPredicate = predicate()
        expenseModelController.observeExpenseEntries(filterPredicate: filterPredicate) { [weak self] expenseEntries in
            guard let self = self else {
                return
            }

            let showNoExpensesView = expenseEntries.count == 0
            self.toggleNoExpensesView?(showNoExpensesView)
            
            changeOccured(self.groupedByDay(expenses: expenseEntries))
        }
    }

    private func predicate() -> NSPredicate? {
        let categoryPredicate = NSPredicate(format: "category.id == %@", expenseCategoryStatsDTO.categoryID)
        let datePredicate: NSPredicate
        let date = expenseCategoryStatsDTO.representationDate
        
        switch expenseCategoryStatsDTO.representationGranularity {
        case .day:
            let creationDateComponentsToStore = Set<Calendar.Component>(arrayLiteral: .year, .month, .day)
            let components = Calendar.current.dateComponents(creationDateComponentsToStore, from: date)

            guard let day = components.day,
                let month = components.month,
                let year = components.year else {
                return nil
            }

            datePredicate = NSPredicate(format: "day == %d AND month == %d AND year == %d", day, month, year)
        case .month:
            let creationDateComponentsToStore = Set<Calendar.Component>(arrayLiteral: .year, .month)
            let components = Calendar.current.dateComponents(creationDateComponentsToStore, from: date)

            guard let month = components.month,
                let year = components.year else {
                return nil
            }
            
            datePredicate = NSPredicate(format: "month == %d AND year == %d", month, year)
        default:
            return nil
        }

        return NSCompoundPredicate.init(type: .and, subpredicates: [categoryPredicate, datePredicate])
    }
    
    private func observeCategoryChanges() {
        expenseCategoryModelController.observeChangesToCategory(with: expenseCategoryStatsDTO.categoryID) { [weak self] updatedCategory in
            guard let category = updatedCategory else {
                return
            }
            self?.categoryTitleChanged?(category.title)
        }
    }
    
}
