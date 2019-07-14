import Foundation
import Intents
import ExpenseKit

class ExpenseCreationIntentHandler: NSObject, CreateExpenseIntentHandling {
    
    @available(iOS 13.0, *)
    func resolveCategory(for intent: CreateExpenseIntent, with completion: @escaping (IntentCategoryResolutionResult) -> Void) {
    }
    
    func provideCategoryOptions(for intent: CreateExpenseIntent, with completion: @escaping ([IntentCategory]?, Error?) -> Void) {
        let modelController = ExpenseCategoryModelController()
        let intentCategories = modelController.storedCategories().map { category in
            IntentCategory(identifier: category.id, display: category.title)
        }
        completion(intentCategories, nil)
    }
    
    @available(iOS 13.0, *)
    func resolveSpentAmount(for intent: CreateExpenseIntent, with completion: @escaping (CreateExpenseSpentAmountResolutionResult) -> Void) {
        
    }

    func handle(intent: CreateExpenseIntent, completion: @escaping (CreateExpenseIntentResponse) -> Void) {
        let response = CreateExpenseIntentResponse(code: .success, userActivity: nil)
        
        completion(response)
    }
    

}
