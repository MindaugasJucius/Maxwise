import UIKit

class ExpenseCreationParentViewController: UIViewController {

    private let nearbyPlacesProvider = NearbyPlacesProvider()
    private var nearbyPlaces: [NearbyPlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        
        nearbyPlacesProvider.performFoursquareNearbyPlaceSearch { [weak self] venues in
            let nearbyPlaces = venues.map(NearbyPlace.init)
            self?.nearbyPlaces = nearbyPlaces
        }
    }
    
    func expenseCreation() -> UIViewController {
        let viewModel = ExpenseCreationViewModel(nearbyPlaces: nearbyPlaces)

        let expenseCreationViewController = ExpenseCreationViewController(viewModel: viewModel)
        return expenseCreationViewController
    }
    
    private func testVenues() -> [Venue] {
        let icon = Icon.init(iconPrefix: "d", suffix: "d")
        let category = Category.init(id: "sd",
                                     name: "weu",
                                     pluralName: "weus",
                                     shortName: "w",
                                     icon: icon,
                                     primary: true)
        let location = Location.init(address: nil, lat: nil, lng: nil, labeledLatLngs: nil, distance: nil, postalCode: nil, cc: nil, city: nil, state: nil, country: nil, formattedAddress: nil)
        let venue1 = Venue(id: "1", name: "Donky donk", location: location, categories: [category], verified: true, referralID: "d", hasPerk: false)
        let venue2 = Venue(id: "2", name: "Donky donkdonk", location: location, categories: [category], verified: true, referralID: "d", hasPerk: false)
        let venue3 = Venue(id: "2", name: "Donky donkdonkdonkdonk", location: location, categories: [category], verified: true, referralID: "d", hasPerk: false)
        let testVenues: [Venue] = [venue1, venue2, venue3]
        return testVenues
    }
    
}
