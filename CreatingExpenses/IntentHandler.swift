//
//  IntentHandler.swift
//  CreatingExpenses
//
//  Created by Mindaugas Jucius on 7/7/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return ExpenseCreationIntentHandler()
    }
    
}
