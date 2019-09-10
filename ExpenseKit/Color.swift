import Foundation
import RealmSwift

public class Color: Object {
    
    @objc public dynamic var id: String! = ""
    @objc public dynamic var title = ""
    @objc public dynamic var hexValue = ""
    @objc public dynamic var taken: Bool = false

    public var uiColor: UIColor? {
        return UIColor(hex: hexValue)
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
