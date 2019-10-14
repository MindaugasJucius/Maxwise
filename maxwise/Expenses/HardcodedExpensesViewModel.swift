import Foundation
import ExpenseKit

class HardcodedExpensesViewModel: ExpensesViewModel {
    
    private let expenseEntries: [ExpenseEntry]
    
    init(expensesToShow expenseEntries: [ExpenseEntry]) {
        self.expenseEntries = expenseEntries
    }
    
    override func observeExpenseEntries(changeOccured: @escaping (GroupedExpenses) -> Void) {
        toggleNoExpensesView?(false)
        let grouped = super.groupedByDay(expenses: expenseEntries)
        changeOccured(grouped)
    }
}
