import RealmSwift

struct ExpenseEntryDTO {
    let id: String
    let amount: Double
    let title: String
    let date: Date
    let image: UIImage?
}

class ExpenseEntryModelController {
    
    func create(image: UIImage, recognizedDouble: Double) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = recognizedDouble
        expenseEntry.imageData = imageData
        expenseEntry.title = "Groceries"
        expenseEntry.id = UUID.init().uuidString
        
        guard let realm = try? Realm() else {
            return
        }

        try? realm.write {
            realm.add(expenseEntry)
        }
    
        print("all expenses")
        realm.objects(ExpenseEntry.self).forEach { entry in
            print(entry.id, entry.amount)
        }
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
