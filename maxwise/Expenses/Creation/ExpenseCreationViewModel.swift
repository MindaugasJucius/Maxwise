import Foundation
import UIKit

class ExpenseCreationViewModel {
    
    private let expenseEntryModelController = ExpenseEntryModelController()
    private let userModelController = UserModelController()
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private var recognizedDouble: Double = 0.0

    let nearbyPlaces: [NearbyPlace]
    var categories: [ExpenseCategory] {
        return expenseCategoryModelController.storedCategories()
    }

    lazy var recognitionOccured: (Double) -> (String) = {
        return { [weak self] recognizedNumber in
            guard let self = self else { fatalError() }
            self.recognizedDouble = recognizedNumber
            return self.formatted(amount: recognizedNumber)
        }
    }()
    
    
    init(nearbyPlaces: [NearbyPlace]) {
        self.nearbyPlaces = nearbyPlaces
    }
    
    private func formatted(amount: Double) -> String {
        let amountNumber = NSNumber(value: amount)
        let formattedAmount = currencyFormatter.string(from: amountNumber) ?? "😬"
        return formattedAmount
    }
    
    func performModelCreation(selectedPlace: NearbyPlace?, seletedCategory: ExpenseCategory) {
        guard let user = try? userModelController.currentUserOrCreate() else {
            return
        }
        expenseEntryModelController.create(user: user,
                                           nearbyPlace: selectedPlace,
                                           category: seletedCategory,
                                           recognizedDouble: recognizedDouble,
                                           title: seletedCategory.title)
    }
    
}
