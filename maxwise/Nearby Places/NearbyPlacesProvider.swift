//
//  NearbyPlaces.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 2/20/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import CoreLocation
import MapKit
import FoursquareAPIClient

class NearbyPlacesProvider: NSObject {

    private let locationManager = CLLocationManager()
    private var currentLocation: ((CLLocation) -> ())?
    
    private var currentQuery: String = ""
    private let foursquareClient = FoursquareAPIClient(
        clientId: "V5FOXP35PN2Q30XB22P4OEF1YQPEEZIBHGJM1QHEG0HDORGA",
        clientSecret: "GDTYPNJJXWNHC5OD2KSOBW4EDZR3AUYFE2ILHZDKSUEOXH4O"
    )
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func performFoursquareNearbyPlaceSearch(completion: @escaping ([Venue]) -> ()) {
        requestLocationAccessIfNeeded { [weak self] in
            self?.locationManager.requestLocation()
            self?.currentLocation = { location in
                self?.foursquareSearch(location: location, completion: completion)
            }
        }
    }
    
    private func foursquareSearch(location: CLLocation,
                                  completion: @escaping ([Venue]) -> ()) {
        let parameters = foursquareParameters(location: location)
        
        foursquareClient.request(path: "venues/search", parameter: parameters) { result in
            switch result {
            case let .success(data):
                let decoder = JSONDecoder.init()
                do {
                    let parsedVenuesSearch = try decoder.decode(VenuesSearch.self, from: data)
                    completion(parsedVenuesSearch.response.venues)
                } catch let error {
                    print(error.localizedDescription)
                }
            case let .failure(error):
                // Error handling
                switch error {
                case let .connectionError(connectionError):
                    print(connectionError)
                case let .responseParseError(responseParseError):
                    print(responseParseError)   // e.g. JSON text did not start with array or object and option to allow fragments not set.
                case let .apiError(apiError):
                    print(apiError.errorType)   // e.g. endpoint_error
                    print(apiError.errorDetail) // e.g. The requested path does not exist.
                }
            }
        }
    }
    
    func places(for query: String) {
        locationManager.requestLocation()
        currentQuery = query
    }
    
    private func requestLocationAccessIfNeeded(granted: () -> ()) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            granted()
        case .denied, .restricted:
            print("can't perform location search")
        }
    }
    
    private func performSearch(location: CLLocation) {
        let request = MKLocalSearch.Request.init()
        request.region = MKCoordinateRegion.init(center: location.coordinate,
                                                 latitudinalMeters: 3000,
                                                 longitudinalMeters: 3000)
        request.naturalLanguageQuery = currentQuery
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { (response, error) in
            response?.mapItems.forEach {
                print("\(String(describing: $0.name)) \(String(describing: $0.placemark.title))")
            }
            print("--------------DONE--------------DONE")
        }
    }
    
    private func foursquareParameters(location: CLLocation) -> [String:String] {
        /// Arts & Entertainment
        /// Food
        /// Nightlife Spot
        /// Shop & Service
        /// Travel & Transport
        /// https://developer.foursquare.com/docs/resources/categories
        let categoryIds = """
            4d4b7104d754a06370d81259,
            4d4b7105d754a06374d81259,
            4d4b7105d754a06376d81259,
            4d4b7105d754a06378d81259,
            4d4b7105d754a06379d81259
        """
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: "")
        
        let parameters = [
            "ll":"\(location.coordinate.latitude),\(location.coordinate.longitude)",
            "radius":"100",
            "limit":"1",
            "categoryId":categoryIds
        ]
        return parameters
    }
    
}

extension NearbyPlacesProvider: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        currentLocation?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
             print("addd")
        case .authorizedWhenInUse, .authorizedAlways:
            print("hurrah")
        case .denied, .restricted:
            print("oh no")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
