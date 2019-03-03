import CoreLocation

typealias EmptyCallback = () -> ()

class LocationAccessNotifier: NSObject {
    
    static let shared = LocationAccessNotifier()
    
    private let locationManager = CLLocationManager()
    
    private var granted: EmptyCallback?
    
    var accessRevoked: EmptyCallback?
    
    func requestLocationAccessIfNeeded(granted: @escaping EmptyCallback) {
        self.granted = granted
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            granted()
        case .denied, .restricted:
            accessRevoked?()
        }
    }
    
}

extension LocationAccessNotifier: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("notDetermined")
        case .authorizedWhenInUse, .authorizedAlways:
            granted?()
        case .denied, .restricted:
            accessRevoked?()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}
