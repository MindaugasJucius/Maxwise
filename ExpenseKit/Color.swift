import Foundation
import RealmSwift

public class Color: Object {
    
    @objc public dynamic var id: String! = ""
    @objc public dynamic var hexValue = ""
    @objc public dynamic var taken: Bool = false

    public var uiColor: UIColor? {
        return UIColor(hex: hexValue)
    }
    
    static func create(from uiColor: UIColor) -> Color {
        let color = Color()
        color.id = NSUUID().uuidString
        color.hexValue = (try? uiColor.hexStringThrows(false)) ?? ""
        return color
    }
    
    override public static func primaryKey() -> String? {
        return "id"
    }
}
