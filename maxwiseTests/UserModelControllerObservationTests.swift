//
//  UserModelControllerObservationTests.swift
//  maxwiseTests
//
//  Created by Mindaugas Jucius on 2/17/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import XCTest
import RealmSwift
@testable import maxwise

class UserModelControllerObservationTests: XCTestCase {

    override func setUp() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testAddingExpenseInvokesAmountObservationBlock() {
        let expectation = XCTestExpectation(description: "amount change block invoked")
        
        let userModelController = UserModelController()
        do {
            let currentUser = try userModelController.currentUserOrCreate()
            let amount = 1.9
            
            userModelController.observeAmountSpent(forUser: currentUser) { retrievedAmount in
                XCTAssert(retrievedAmount == amount)
                expectation.fulfill()
            }
            
            _ = TestsHelper.createExpense(user: currentUser,
                                          amount: amount,
                                          title: "test expense")
            
            wait(for: [expectation], timeout: 3)
        } catch let error {
            XCTFail("\(error)")
        }
    }

}
