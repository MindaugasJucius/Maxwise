//
//  ExpenseCreationIntentHandler.swift
//  maxwise
//
//  Created by Mindaugas Jucius on 7/8/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import Foundation
import Intents

class ExpenseCreationIntentHandler: NSObject, CreateExpenseIntentHandling {
    
    @available(iOS 13.0, *)
    func resolveAmount(for intent: CreateExpenseIntent, with completion: @escaping (CreateExpenseAmountResolutionResult) -> Void) {
        guard let currencyAmount = intent.amount else {
            
            completion(.needsValue())
            return
        }

        completion(.success(with: currencyAmount))
    }
    
    @available(iOS 13.0, *)
    func resolveCategory(for intent: CreateExpenseIntent, with completion: @escaping (EnumResolutionResult) -> Void) {
        completion(.success(with: intent.category))
    }
    
    
    func handle(intent: CreateExpenseIntent, completion: @escaping (CreateExpenseIntentResponse) -> Void) {
        let response = CreateExpenseIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
    

}
