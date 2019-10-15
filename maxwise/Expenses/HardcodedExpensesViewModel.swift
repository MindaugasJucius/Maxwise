import Foundation
import ExpenseKit

class HardcodedExpensesViewModel: ExpensesViewModel {
    
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    private let expenseModelController = ExpenseEntryModelController()
    
    let categoryID: String
    let date: Date

    private var changeOccured: ((GroupedExpenses) -> Void)?
    
    init(categoryID: String, date: Date) {
        self.categoryID = categoryID
        self.date = date
    }
    
    override func observeExpenseEntries(changeOccured: @escaping (GroupedExpenses) -> Void) {
        self.changeOccured = changeOccured
        fetchAndInvokeChangeHandler()
    }
    
    override func delete(expense: ExpensePresentationDTO, completion: (Result<Void, Error>) -> ()) {
        let completionCheck: (Result<Void, Error>) -> () = { [weak self] result in
            switch result {
            case .success(_):
                self?.fetchAndInvokeChangeHandler()
            default:
                print("")
            }
            completion(result)
        }
        super.delete(expense: expense, completion: completionCheck)
    }

    private func fetchAndInvokeChangeHandler() {
        let grouped = groupedByDay(expenses: expenses())
        changeOccured?(grouped)
        toggleNoExpensesView?(grouped.isEmpty)
    }
    
    private func expenses() -> [ExpenseEntry] {
        guard let category = expenseCategoryModelController.category(from: categoryID) else {
            return []
        }

        return expenseModelController.filter(expenses: Array(category.expenses), by: date)
    }
    
}
