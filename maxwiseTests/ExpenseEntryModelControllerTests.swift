import XCTest
import RealmSwift
@testable import maxwise

class ExpenseEntryModelControllerTests: XCTestCase {

    override func setUp() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    

    
}
