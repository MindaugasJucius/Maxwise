import RealmSwift
@testable import maxwise

class TestsHelper {
    
    static func createExpense(user: User, amount: Double, title: String) -> ExpenseEntry {
        let expenseModelController = ExpenseEntryModelController()
        return expenseModelController.create(user: user,
                                             image: nil,
                                             recognizedDouble: amount,
                                             title: title)
    }
    
}
