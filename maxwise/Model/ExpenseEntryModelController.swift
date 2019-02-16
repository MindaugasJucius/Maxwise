import RealmSwift

struct ExpenseEntryDTO {
    let id: String
    let amount: Double
    let title: String
    let date: Date
    let image: UIImage?
}

class ExpenseEntryModelController {
    
    @discardableResult
    func create(user: User,
                image: UIImage?,
                recognizedDouble: Double,
                title: String) -> ExpenseEntry {
        
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = recognizedDouble
        expenseEntry.imageData = image?.jpegData(compressionQuality: 0.5)
        expenseEntry.title = title
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
    
    func retrieveAllExpenseEntries() -> [ExpenseEntryDTO] {
        guard let realm = try? Realm() else {
            return []
        }
        let arrayEntries = Array(realm.objects(ExpenseEntry.self))
        let mappedEntries = arrayEntries.map { entry -> ExpenseEntryDTO in
            var image: UIImage? = nil
            if let imageData = entry.imageData {
                let deserializedImage = UIImage(data: imageData)
                image = deserializedImage
            }
            
            let dto = ExpenseEntryDTO(id: entry.id,
                                      amount: entry.amount,
                                      title: entry.title,
                                      date: entry.creationDate,
                                      image: image)
            return dto
        }
        return mappedEntries
    }
    
}
