import RealmSwift
import ExpenseKit
@testable import maxwise

class TestsHelper {
    
    
    
    static let expenseModelController = ExpenseEntryModelController()
    
    
    static func clearRealm() {
        let realm = try! Realm.groupRealm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    static func createExpense(user: User,
                              amount: Double,
                              title: String,
                              completion: (Result<ExpenseEntry, CreationIssue>) -> ()) {

        let category = ExpenseCategory()
        category.id = NSUUID().uuidString
        let dto = ExpenseDTO.init(title: title,
                        category: category, // cia problema
                        user: user,
                        place: nil,
                        amount: amount,
                        shareAmount: .full)
        expenseModelController.create(expenseDTO: dto, completion: completion)
    }
    
}
