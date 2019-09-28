//
//  maxwiseTests.swift
//  maxwiseTests
//
//  Created by Mindaugas Jucius on 2/3/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import XCTest
import RealmSwift
import ExpenseKit
@testable import maxwise

class UserModelControllerTests: XCTestCase {

    override func setUp() {
        TestsHelper.clearRealm()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUserIsTheSameOnMultipleCurrentUserOrCreate() {
        let userModelController = UserModelController()
        do {
            let firstInvocation = try userModelController.currentUserOrCreate()
            let secondInvocation = try userModelController.currentUserOrCreate()
            XCTAssert(firstInvocation.id == secondInvocation.id)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingExpenseCurrentUserExpensesCountIncreases() {
        let userModelController = UserModelController()
        do {
            let currentUser = try userModelController.currentUserOrCreate()
            let expensesToCreateCount = 3
            for amount in 0..<expensesToCreateCount {
                TestsHelper.createExpense(user: currentUser, amount: Double(amount), title: "expense") { _ in
                    
                }
            }
            XCTAssert(currentUser.entries.count == expensesToCreateCount)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingExpenseForUserOwnerIsUser() {
        let userModelController = UserModelController()
        let expectation = XCTestExpectation(description: "owner is user")
        do {
            let currentUser = try userModelController.currentUserOrCreate()
            let amount = 1.9
            TestsHelper.createExpense(user: currentUser, amount: Double(amount), title: "expense") { result in
                switch result {
                case .failure(let issue):
                    XCTFail(issue.localizedDescription)
                case .success(let expense):
                    XCTAssert(expense.owners.first?.id == currentUser.id)
                    expectation.fulfill()
                }
            }
            wait(for: [expectation], timeout: 3)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
}
