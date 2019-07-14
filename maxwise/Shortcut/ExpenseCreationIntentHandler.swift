import Foundation
import Intents

class ExpenseCreationIntentHandler: NSObject, CreateExpenseIntentHandling {
    
    @available(iOS 13.0, *)
    func resolveCategory(for intent: CreateExpenseIntent, with completion: @escaping (IntentCategoryResolutionResult) -> Void) {
        
    }
    
    func provideCategoryOptions(for intent: CreateExpenseIntent, with completion: @escaping ([IntentCategory]?, Error?) -> Void) {
        
    }
    
    @available(iOS 13.0, *)
    func resolveSpentAmount(for intent: CreateExpenseIntent, with completion: @escaping (CreateExpenseSpentAmountResolutionResult) -> Void) {
        
    }

    func handle(intent: CreateExpenseIntent, completion: @escaping (CreateExpenseIntentResponse) -> Void) {
        let response = CreateExpenseIntentResponse(code: .success, userActivity: nil)
        
        completion(response)
    }
    

}
