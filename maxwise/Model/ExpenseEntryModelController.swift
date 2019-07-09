import RealmSwift
import Intents

enum CreationIssue: Error {
    case noAmount
    case noCategory
    case alert(String)
}

class ExpenseEntryModelController {

    private var expenseEntryObservationToken: NotificationToken?
    
    func create(user: User,
                nearbyPlace: NearbyPlace?,
                category: ExpenseCategory,
                recognizedDouble: Double,
                title: String,
                completion: (Result<Void, CreationIssue>) -> ()) {
        
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = recognizedDouble
        expenseEntry.category = category
        expenseEntry.title = title
        expenseEntry.place = nearbyPlace
        expenseEntry.id = UUID.init().uuidString

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(expenseEntry)
                user.entries.append(expenseEntry)
            }
            donateCreateExpense(expense: expenseEntry)
            completion(.success(()))
        } catch let error {
            completion(.error(.alert(error.localizedDescription)))
        }
    }

    func observeExpenseEntries(updated: @escaping ([ExpenseEntry]) -> ()) {
        let realm = try? Realm()
        expenseEntryObservationToken = realm?.objects(ExpenseEntry.self).observe { change in
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
    
    func retrieveAllExpenseEntries() -> [ExpenseEntry] {
        guard let realm = try? Realm() else {
            return []
        }
        let arrayEntries = Array(realm.objects(ExpenseEntry.self))
        
        return arrayEntries
    }
    
    func donateCreateExpense(expense: ExpenseEntry) {
        guard let currentCode = Locale.current.currencyCode else {
            return
        }
        let currencyAmount = INCurrencyAmount(amount: NSDecimalNumber(value: expense.amount),
                                              currencyCode: currentCode)
        let intent = CreateExpenseIntent()
        intent.amount = currencyAmount
        intent.category = .entertainment

        let interaction = INInteraction(intent: intent, response: nil)

        interaction.donate { error in
            print(error?.localizedDescription)
        }
    }

}
