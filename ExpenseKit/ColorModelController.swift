import Foundation
import RealmSwift

public class ColorModelController {

    private let defaultColorsCreatedKey = "defaultColorsCreated"

    public init() {
        
    }

    public func savePaletteColors(completed: () -> ())  {
        guard !UserDefaults.standard.bool(forKey: defaultColorsCreatedKey) else {
            return
        }

        UIColor.palette.forEach {
            store(uiColor: $0)
        }
        
        completed()
        
        UserDefaults.standard.set(true, forKey: defaultColorsCreatedKey)
    }
    
    public func saveDefaultCategoryColors(colors: [UIColor], completed: ([UIColor: Color]) -> ()) {
        var defaultColorPairs = [UIColor: Color]()
        colors.forEach {
            defaultColorPairs[$0] = Color.create(from: $0)
        }

        defaultColorPairs.values.forEach {
            store(color: $0)
        }
        
        completed(defaultColorPairs)
    }
    
    public func notTakenColors() -> [Color] {
        guard let colors = colors() else {
            return []
        }
        return Array(colors.filter { !$0.taken })
    }
    
    public func takenColors() -> [Color] {
        guard let colors = colors() else {
            return []
        }
        return Array(colors.filter { $0.taken })
    }
    
    public func randomNonTakenColor() -> Color? {
        return notTakenColors().randomElement()
    }
    
    func colors() -> Results<Color>? {
        guard let realm = try? Realm.groupRealm() else {
            return nil
        }
        
        return realm.objects(Color.self)
    }
    
    public func store(uiColor: UIColor) {
        let color = Color.create(from: uiColor)
        store(color: color)
    }
    
    public func store(color: Color) {
        guard let realm = try? Realm.groupRealm() else {
            return
        }
        
        try? realm.write {
            realm.add(color)
        }
    }
}
