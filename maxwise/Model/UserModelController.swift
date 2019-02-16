import RealmSwift

enum UserModelError: Error {
    case failedToCreateRealm
}

class UserModelController {

    func currentUserOrCreate() throws -> User {
        guard let realm = try? Realm() else {
            throw UserModelError.failedToCreateRealm
        }
        
        guard let user = realm.objects(User.self).first else {
            return createUser(realm: realm)
        }
        
        return user
    }
    
    func amountSpent(forUser user: User) -> Double {
        return user.entries.reduce(0.0) { (current, expenseEntry) -> Double in
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
