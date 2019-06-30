import Foundation
import UIKit

class ExpenseCreationViewModel {
    
    private struct ExpenseDTO {
        let category: ExpenseCategory
        let user: User
        let place: NearbyPlace?
        let amount: Double
    }
        
    private let expenseEntryModelController = ExpenseEntryModelController()
    private let userModelController = UserModelController()
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private var recognizedDouble: Double?
    
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
    
    func performModelCreation(selectedPlace: NearbyPlace?, categoryID: String?, result: (Result<Void, [CreationIssue]>) -> ()) {
        let validationResult = validate(selectedPlace: selectedPlace, categoryID: categoryID)
        switch validationResult {
        case .error(let issues):
            result(.error(issues))
        case .success(let dto):
            expenseEntryModelController.create(
                user: dto.user,
                nearbyPlace: dto.place,
                category: dto.category,
                recognizedDouble: dto.amount,
                title: dto.category.title,
                completion: { creationResult in
                    switch creationResult {
                    case .error(let error):
                        result(.error([error]))
                    case .success(_):
                        result(.success(()))
                    }
                }
            )
        }
    }
    
    private func validate(selectedPlace: NearbyPlace?, categoryID: String?) -> Result<ExpenseDTO, [CreationIssue]> {
        var issues: [CreationIssue] = []
        
        let filteredSelected = categories.filter { $0.id == categoryID }

        let category    = retrieve(from: filteredSelected.first, issue: .noCategory, issues: &issues)
        
        let noUserCanBeCreated = CreationIssue.alert("User can't be created")
        let user        = retrieve(from: try? userModelController.currentUserOrCreate(), issue: noUserCanBeCreated, issues: &issues)
        let recognition = retrieve(from: recognizedDouble, issue: .noAmount, issues: &issues)

        guard let categoryValue = category, let userValue = user, let recognitionValue = recognition else {
            return .error(issues)
        }

        let expenseDTO = ExpenseDTO(category: categoryValue, user: userValue, place: nil, amount: recognitionValue)
        return .success(expenseDTO)
    }
    
    private func retrieve<T>(from value: T?, issue: CreationIssue, issues: inout [CreationIssue]) -> T? {
        guard let value = value else {
            issues.append(issue)
            return nil
        }
        
        return value
    }
}
