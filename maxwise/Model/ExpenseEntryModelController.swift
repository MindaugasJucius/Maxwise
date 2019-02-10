import RealmSwift

class ExpenseEntryModelController {
    
    func create(image: UIImage, recognizedDouble: Double) {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = recognizedDouble
        expenseEntry.imageData = imageData
        expenseEntry.id = UUID.init().uuidString
        
        guard let realm = try? Realm() else {
            return
        }

        try? realm.write {
            realm.add(expenseEntry)
        }
    }
        
}
