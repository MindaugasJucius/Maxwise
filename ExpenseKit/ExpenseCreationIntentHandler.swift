import Foundation
import Intents
import ExpenseKit

class ExpenseCreationIntentHandler: NSObject, CreateExpenseIntentHandling {
    
    func provideCategoryOptions(for intent: CreateExpenseIntent, with completion: @escaping ([IntentCategory]?, Error?) -> Void) {
        let modelController = ExpenseCategoryModelController()
        let intentCategories = modelController.storedCategories().map { category in
            IntentCategory(identifier: category.id, display: category.title)
        }
        completion(intentCategories, nil)
    }
    
    @available(iOS 13.0, *)
    func resolveSpentAmount(for intent: CreateExpenseIntent, with completion: @escaping (CreateExpenseSpentAmountResolutionResult) -> Void) {
        guard let amount = intent.spentAmount else {
            completion(.needsValue())
            return
        }
        
        guard amount.doubleValue >= 0.01 else {
            completion(.unsupported(forReason: .lessThanMinimumValue))
            return
        }
        
        guard amount.doubleValue < 500 else {
            completion(.confirmationRequired(with: amount.doubleValue))
            return
        }
        
        completion(.success(with: amount.doubleValue))
    }
    
    @available(iOS 13.0, *)
    func resolveCategory(for intent: CreateExpenseIntent, with completion: @escaping (IntentCategoryResolutionResult) -> Void) {
        guard let category = intent.category else {
            completion(.needsValue())
            return
        }
        
        completion(.success(with: category))
    }

    func handle(intent: CreateExpenseIntent, completion: @escaping (CreateExpenseIntentResponse) -> Void) {
        let userModelController = UserModelController()
        guard let user = try? userModelController.currentUserOrCreate() else {
            completion(.init(code: .failedToGetUser, userActivity: nil))
            return
        }
        
        let expenseCategoryModel = ExpenseCategoryModelController()
        
        guard let intentCategory = intent.category,
            let expenseCategory = expenseCategoryModel.category(from: intentCategory) else {
            completion(.init(code: .failedToFindCategory, userActivity: nil))
            return
        }

        guard let amount = intent.spentAmount?.doubleValue else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        
        let expenseModelController = ExpenseEntryModelController()

        expenseModelController.create(user: user,
                                      nearbyPlace: nil,
                                      category: expenseCategory,
                                      recognizedDouble: amount,
                                      title: expenseCategory.title) { result in
            switch result {
            case .success(_):
                completion(.init(code: .success, userActivity: nil))
            case .failure(_):
                completion(.init(code: .failure, userActivity: nil))
            }
        }

    }
    

}
