import Foundation

struct VenuesSearch: Codable {
    let meta: Meta
    let response: Response
}

struct Meta: Codable {
    let code: Int
    let requestID: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case requestID = "requestId"
    }
}

struct Response: Codable {
    let venues: [Venue]
    let confident: Bool
}

struct Venue: Codable {
    let id, name: String
    let location: Location
    let categories: [Category]
    let verified: Bool
    let referralID: String
    let hasPerk: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, location, categories, verified
        case referralID = "referralId"
        case hasPerk
    }
}

struct Category: Codable {
    let id, name, pluralName, shortName: String
    let icon: Icon
    let primary: Bool
}

struct Icon: Codable {
    let iconPrefix: String
    let suffix: String
    
    enum CodingKeys: String, CodingKey {
        case iconPrefix = "prefix"
        case suffix
    }
}

struct Location: Codable {
    let address: String?
    let lat, lng: Double?
    let labeledLatLngs: [LabeledLatLng]?
    let distance: Int?
    let postalCode, cc, city, state: String?
    let country: String?
    let formattedAddress: [String]?
}

struct LabeledLatLng: Codable {
    let label: String
    let lat, lng: Double
}

////
////  NearbyPlace.swift
////  maxwise
////
////  Created by Mindaugas Jucius on 2/23/19.
////  Copyright © 2019 Mindaugas Jucius. All rights reserved.
////
//
//import RealmSwift
//import Realm
//import CoreLocation
//
//@objcMembers
//class NearbyPlace: Object, Decodable {
//
//    enum CodingKeys: String, CodingKey
//    {
//        case id
//        case name
//    }
//
//    // Foursquare id
//    dynamic var id: String = ""
//    dynamic var location: CLLocationCoordinate2D = CLLocationCoordinate2D.init()
//    dynamic var title: String = ""
//    dynamic var categoryTitle: String = ""
//    dynamic var formattedAddress: String = ""
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        super.init()
//    }
//
//    required init(value: Any, schema: RLMSchema) {
//        super.init(value: value, schema: schema)
//    }
//
//    required init() {
//        super.init()
//    }
//
//    required init(realm: RLMRealm, schema: RLMObjectSchema) {
//        super.init(realm: realm, schema: schema)
//    }
//
//}
//
//extension CLLocationCoordinate2D: Codable {
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.unkeyedContainer()
//        try container.encode(longitude)
//        try container.encode(latitude)
//    }
//
//    public init(from decoder: Decoder) throws {
//        var container = try decoder.unkeyedContainer()
//        let longitude = try container.decode(CLLocationDegrees.self)
//        let latitude = try container.decode(CLLocationDegrees.self)
//        self.init(latitude: latitude, longitude: longitude)
//    }
//}
