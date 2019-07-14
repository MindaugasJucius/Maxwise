import Foundation
import RealmSwift

extension Realm {
    
    static func groupRealm() throws -> Realm {
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.mindaugo.appsai.maxwise")
        guard let groupURL = fileURL else {
            fatalError("no groupURL")
        }
        
        let config = Realm.Configuration(fileURL: groupURL.appendingPathComponent("default.realm"))
        return try Realm(configuration: config)
    }

}
