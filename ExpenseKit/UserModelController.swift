import RealmSwift
import Foundation
import UIKit

public enum UserModelError: Error {
    case failedToCreateRealm
}

public class UserModelController {
    
    private var amountObservationToken: NotificationToken?

    public init() {
        
    }
    
    public func currentUserOrCreate() throws -> User {
        do {
            let realm = try Realm.groupRealm()

            guard let user = realm.objects(User.self).first else {
                return try createUser(realm: realm)
            }
            
            return user
        } catch let error {
           throw error
        }
    }
    
    public func observeAmountSpent(forUser user: User, amountChanged: @escaping (Double) -> ()) {
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
    
    private func createUser(realm: Realm) throws -> User {
        let user = User()
        user.id = UUID.init().uuidString
        user.name = UIDevice.current.name
        do {
            try realm.write {
               realm.add(user)
            }
            return user
        } catch let error {
            throw error
        }
    }
    
}
