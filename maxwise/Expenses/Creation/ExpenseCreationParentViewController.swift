import UIKit
import ExpenseKit

class ExpenseCreationParentViewController: UIViewController {

    private let nearbyPlacesProvider = NearbyPlacesProvider()
    private var nearbyPlaces: [NearbyPlace] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    }
    
    func expenseCreation() -> UIViewController {
        let viewModel = ExpenseCreationViewModel(nearbyPlaces: nearbyPlaces)

        let expenseCreationViewController = ExpenseCreationViewController(viewModel: viewModel)
        return expenseCreationViewController
    }
    
}
