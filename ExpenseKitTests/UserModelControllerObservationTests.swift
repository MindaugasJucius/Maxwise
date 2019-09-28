//
//  UserModelControllerObservationTests.swift
//  maxwiseTests
//
//  Created by Mindaugas Jucius on 2/17/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import XCTest
import RealmSwift
import ExpenseKit
@testable import maxwise

class UserModelControllerObservationTests: XCTestCase {

    override func setUp() {
        TestsHelper.clearRealm()
    }

    func testAddingExpenseInvokesAmountObservationBlock() {
        let expectation = XCTestExpectation(description: "amount change block invoked")
        
        let userModelController = UserModelController()
        do {
            let currentUser = try userModelController.currentUserOrCreate()
            let amount = 1.9
            
            var invocationCount = 0
            userModelController.observeAmountSpent(forUser: currentUser) { retrievedAmount in
                //observeAmountSpent calls observation closure immediatelly so we need to
                //skip first invocation because no expenses are persisted at that time.
                
                invocationCount += 1
                if invocationCount == 1 {
                    return
                }
                print(currentUser.entries)
                XCTAssert(retrievedAmount == amount)
                expectation.fulfill()
            }
            
            TestsHelper.createExpense(user: currentUser, amount: amount, title: "test expense") { result in
                switch result {
                case .failure(let issue):
                    XCTFail(issue.localizedDescription)
                case .success(let entry):
                    print("woplia")
                }
            }
            
            wait(for: [expectation], timeout: 3)
        } catch let error {
            XCTFail("\(error)")
        }
    }

}
