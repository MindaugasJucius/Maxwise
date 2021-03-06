import Foundation
import CoreLocation
import RealmSwift
import Realm

public struct VenuesSearch: Codable {
    let meta: Meta
    public let response: Response
}

public struct Meta: Codable {
    let code: Int
    let requestID: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case requestID = "requestId"
    }
}

public struct Response: Codable {
    public let venues: [Venue]
    public let confident: Bool
}

public struct Venue: Codable {
    let id, name: String
    let location: Location
    let categories: [Category]
    let verified: Bool
    let referralID: String
    let hasPerk: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case categories
        case verified
        case referralID = "referralId"
        case hasPerk
    }
}

public struct Category: Codable {
    let id, name, pluralName, shortName: String
    let icon: Icon
    let primary: Bool
}

public struct Icon: Codable {
    let iconPrefix: String
    let suffix: String
    
    enum CodingKeys: String, CodingKey {
        case iconPrefix = "prefix"
        case suffix
    }
}

public struct Location: Codable {
    let address: String?
    let lat, lng: Double?
    let labeledLatLngs: [LabeledLatLng]?
    let distance: Int?
    let postalCode, cc, city, state: String?
    let country: String?
    let formattedAddress: [String]?
}

public struct LabeledLatLng: Codable {
    let label: String
    let lat, lng: Double
}


@objcMembers
public class NearbyPlace: Object {

    dynamic var id: String = ""
    public var lat = RealmOptional<Double>()
    public var lng = RealmOptional<Double>()
    public dynamic var title: String = ""
    public dynamic var categoryTitle: String = ""

    var location: CLLocationCoordinate2D? {
        if let latitude = lat.value,
            let longitude = lng.value {
            return CLLocationCoordinate2D(latitude: latitude,
                                          longitude: longitude)
        }

        return nil
    }
    
    init(venue: Venue) {
        id = venue.id
        title = venue.name
        categoryTitle = venue.categories.first?.name ?? "No name"
        lat.value = venue.location.lat
        lng.value = venue.location.lng
        super.init()
    }
    
    required init() {
        super.init()
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}
