import RealmSwift

class ExpenseEntryModelController {

    private var expenseEntryObservationToken: NotificationToken?
    
    @discardableResult
    func create(user: User,
                nearbyPlace: NearbyPlace?,
                category: ExpenseCategory,
                recognizedDouble: Double,
                title: String) -> ExpenseEntry {
        
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = recognizedDouble
        expenseEntry.category = category
        expenseEntry.title = title
        expenseEntry.place = nearbyPlace
        expenseEntry.id = UUID.init().uuidString

        guard let realm = try? Realm() else {
            print("expense not persisted")
            return expenseEntry
        }

        try? realm.write {
            realm.add(expenseEntry)
            user.entries.append(expenseEntry)
        }
        
        return expenseEntry
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
    
}
