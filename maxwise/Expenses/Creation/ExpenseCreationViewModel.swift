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
    
    private var recognizedDouble: Double?
    
    let nearbyPlaces: [NearbyPlace]
    var categories: [ExpenseCategory] {
        return expenseCategoryModelController.storedCategories()
    }
    
    init(nearbyPlaces: [NearbyPlace]) {
        self.nearbyPlaces = nearbyPlaces
    }
    
    func performModelCreation(amount: Double?, selectedPlace: NearbyPlace?, categoryID: String?, result: (Result<Void, [CreationIssue]>) -> ()) {
        recognizedDouble = amount
        
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
