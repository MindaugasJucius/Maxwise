import UIKit

class ExpensesViewModel {

    private let modelController = ExpenseEntryModelController()
    
    func expenseEntries() -> [ExpenseEntryDTO] {
        return modelController.retrieveAllExpenseEntries()
    }
    
}
