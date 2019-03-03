import RealmSwift

class ExpenseEntryModelController {
    
    @discardableResult
    func create(user: User,
                nearbyPlace: NearbyPlace?,
                image: UIImage?,
                recognizedDouble: Double,
                title: String) -> ExpenseEntry {
        
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = recognizedDouble
        expenseEntry.imageData = image?.jpegData(compressionQuality: 0.5)
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
    
    func retrieveAllExpenseEntries() -> [ExpenseEntry] {
        guard let realm = try? Realm() else {
            return []
        }
        let arrayEntries = Array(realm.objects(ExpenseEntry.self))
        
        return arrayEntries
    }
    
}
