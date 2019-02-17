import RealmSwift

enum UserModelError: Error {
    case failedToCreateRealm
}

class UserModelController {
    
    private var amountObservationToken: NotificationToken?
    
    func currentUserOrCreate() throws -> User {
        guard let realm = try? Realm() else {
            throw UserModelError.failedToCreateRealm
        }
        
        guard let user = realm.objects(User.self).first else {
            return createUser(realm: realm)
        }
        
        return user
    }
    
    func observeAmountSpent(forUser user: User, amountChanged: @escaping (Double) -> ()) {
        // Initial value notification
        amountChanged(amountSpent(entries: user.entries))
        
        amountObservationToken = user.observe { [weak self] change in
            guard let self = self else {
                return
            }
            
            switch change {
            case .change(let properties):
                for property in properties {
                    if property.name == "entries",
                        let entries = property.newValue as? List<ExpenseEntry> {
                        amountChanged(self.amountSpent(entries: entries))
                    }
                }
            case .error(let error):
                print("An error occurred: \(error)")
            case .deleted:
                print("The object was deleted.")
            }
        }
    }

    
    private func amountSpent(entries: List<ExpenseEntry>) -> Double {
        return entries.reduce(0.0) { (current, expenseEntry) -> Double in
            return current + expenseEntry.amount
        }
    }
    
    private func createUser(realm: Realm) -> User {
        let user = User()
        user.id = UUID.init().uuidString
        user.name = UIDevice.current.name
        try? realm.write {
           realm.add(user)
        }
        return user
    }
    
}
