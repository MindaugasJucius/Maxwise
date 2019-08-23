import RealmSwift
import Intents

public enum CreationIssue: Error {
    case noAmount
    case noCategory
    case alert(String)
}

public class ExpenseEntryModelController {

    private var expenseEntryObservationToken: NotificationToken?
    
    public init() {
        
    }
    
    public func create(expenseDTO: ExpenseDTO,
                       completion: (Result<Void, CreationIssue>) -> ()) {
        
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = expenseDTO.amount
        expenseEntry.category = expenseDTO.category
        expenseEntry.title = expenseDTO.category.title
        expenseEntry.place = expenseDTO.place
        expenseEntry.id = UUID.init().uuidString
        expenseEntry.sharePercentage = expenseDTO.shareAmount.rawValue
        do {
            let realm = try Realm.groupRealm()
            try realm.write {
                realm.add(expenseEntry)
                expenseDTO.user.entries.append(expenseEntry)
            }
            donateCreateExpense(expense: expenseEntry)
            completion(.success(()))
        } catch let error {
            completion(.failure(.alert(error.localizedDescription)))
        }
    }

    public func observeExpenseEntries(updated: @escaping ([ExpenseEntry]) -> ()) {
        let realm = try? Realm.groupRealm()
        let expenseEntries = realm?.objects(ExpenseEntry.self)
            .sorted(byKeyPath: "creationDate", ascending: false)
        expenseEntryObservationToken = expenseEntries?.observe { change in
            switch change {
            case .initial(let value):
                updated(Array(value))
            case .update(let value, deletions: _, insertions: _, modifications: _):
                updated(Array(value))
            default:
                print("huh")
            }
        }
    }
    
    public func retrieveAllExpenseEntries() -> [ExpenseEntry] {
        guard let realm = try? Realm.groupRealm() else {
            return []
        }
        let arrayEntries = Array(realm.objects(ExpenseEntry.self))
        
        return arrayEntries
    }
    
    public func donateCreateExpense(expense: ExpenseEntry) {
        guard let currencyCode = Locale.current.currencyCode else {
            return
        }
        let intent = CreateExpenseIntent()

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.identifier = expense.id
        
        interaction.donate { error in
            print(error?.localizedDescription)
        }
    }

}
