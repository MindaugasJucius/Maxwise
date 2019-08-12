import Foundation
import UIKit
import ExpenseKit

enum ValidationResult<T> {
    case success(T)
    case failure([CreationIssue])
}

class ExpenseCreationViewModel {
    
    private let expenseEntryModelController = ExpenseEntryModelController()
    private let userModelController = UserModelController()
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    
    private var expenseAmountDouble: Double?
    
    let nearbyPlaces: [NearbyPlace]
    
    var categories: [ExpenseCategory] {
        return expenseCategoryModelController.storedCategories()
    }
    
    var percentages: [ExpenseDTO.SharePercentage] = [.full, .half]
    
    init(nearbyPlaces: [NearbyPlace]) {
        self.nearbyPlaces = nearbyPlaces
    }
    
    func performModelCreation(amount: Double?, selectedPlace: NearbyPlace?, categoryID: String?, sharePercentage: ExpenseDTO.SharePercentage, result: (ValidationResult<Void>) -> ()) {
        expenseAmountDouble = amount
        
        let validationResult = validate(selectedPlace: selectedPlace,
                                        categoryID: categoryID,
                                        sharePercentage: sharePercentage)
        switch validationResult {
        case .failure(let issues):
            result(.failure(issues))
        case .success(let dto):
            expenseEntryModelController.create(expenseDTO: dto) { creationResult in
                switch creationResult {
                case .failure(let error):
                    result(.failure([error]))
                case .success(_):
                    result(.success(()))
                }
            }
        }
    }
    
    private func validate(selectedPlace: NearbyPlace?,
                          categoryID: String?,
                          sharePercentage: ExpenseDTO.SharePercentage) -> ValidationResult<ExpenseDTO> {
        var issues: [CreationIssue] = []
        
        let filteredSelected = categories.filter { $0.id == categoryID }

        let category = retrieve(from: filteredSelected.first, issue: .noCategory, issues: &issues)
        
        let noUserCanBeCreated = CreationIssue.alert("User can't be created")
        let user = retrieve(from: try? userModelController.currentUserOrCreate(), issue: noUserCanBeCreated, issues: &issues)
        let expenseAmount = retrieve(from: expenseAmountDouble, issue: .noAmount, issues: &issues)

        guard let amount = expenseAmount, amount > 0 else {
            issues.append(.noAmount)
            return .failure(issues)
        }
        
        guard let categoryValue = category, let userValue = user else {
            return .failure(issues)
        }

        let expenseDTO = ExpenseDTO(category: categoryValue,
                                    user: userValue,
                                    place: nil,
                                    amount: amount,
                                    shareAmount: sharePercentage)
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
