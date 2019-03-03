import Foundation
import UIKit

class ExpenseCreationViewModel {
    
    private let expenseEntryModelController = ExpenseEntryModelController()
    private let userModelController = UserModelController()
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private let recognizedDouble: Double
    private let image: UIImage?
    private(set) var formattedValue: String = ""
    let nearbyPlaces: [NearbyPlace]
    
    init(recognizedDouble: Double, image: UIImage?, nearbyPlaces: [NearbyPlace]) {
        self.recognizedDouble = recognizedDouble
        self.nearbyPlaces = nearbyPlaces
        self.image = image
        formattedValue = formatted(amount: recognizedDouble)
    }
    
    private func formatted(amount: Double) -> String {
        let amountNumber = NSNumber(value: amount)
        let formattedAmount = currencyFormatter.string(from: amountNumber) ?? "😬"
        return formattedAmount
    }
    
    func performModelCreation(selectedPlace: NearbyPlace?) {
        guard let user = try? userModelController.currentUserOrCreate() else {
            return
        }
        expenseEntryModelController.create(user: user,
                                           nearbyPlace: selectedPlace,
                                           image: image,
                                           recognizedDouble: recognizedDouble,
                                           title: "Groceries")
    }
    
}
