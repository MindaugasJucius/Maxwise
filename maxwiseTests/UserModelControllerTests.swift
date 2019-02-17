//
//  maxwiseTests.swift
//  maxwiseTests
//
//  Created by Mindaugas Jucius on 2/3/19.
//  Copyright © 2019 Mindaugas Jucius. All rights reserved.
//

import XCTest
import RealmSwift
@testable import maxwise

class UserModelControllerTests: XCTestCase {

    override func setUp() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
                _ = TestsHelper.createExpense(user: currentUser,
                                              amount: Double(amount),
                                              title: "test expense")
            }
            XCTAssert(currentUser.entries.count == expensesToCreateCount)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingExpenseForUserOwnerIsUser() {
        let userModelController = UserModelController()
        do {
            let currentUser = try userModelController.currentUserOrCreate()
            let amount = 1.9
            let expense = TestsHelper.createExpense(user: currentUser,
                                                    amount: amount,
                                                    title: "test expense")
            XCTAssert(expense.owners.first?.id == currentUser.id)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
}
