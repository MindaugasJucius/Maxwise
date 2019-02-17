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
                _ = createExpense(user: currentUser,
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
            let expense = createExpense(user: currentUser,
                                        amount: amount,
                                        title: "test expense")
            XCTAssert(expense.owners.first?.id == currentUser.id)
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingExpensesForUsersIncreasesAmountSpent() {
        let userModelController = UserModelController()
        do {
            let currentUser = try userModelController.currentUserOrCreate()
            let amounts = [0.5, 10.6, 9.7]
            let expensesToCreateCount = 3
            for index in 0..<expensesToCreateCount {
                _ = createExpense(user: currentUser,
                                  amount: amounts[index],
                                  title: "test expense")
            }
            
            let amountSum = amounts.reduce(0.0, { return $0 + $1 })
            let amountSpent = userModelController.amountSpent(forUser: currentUser)
            XCTAssert(amountSum == amountSpent)
        } catch let error {
            XCTFail("\(error)")
        }

    }

}

extension UserModelControllerTests {
    
    private func createExpense(user: User, amount: Double, title: String) -> ExpenseEntry {
        let expenseModelController = ExpenseEntryModelController()
        return expenseModelController.create(user: user,
                                             image: nil,
                                             recognizedDouble: amount,
                                             title: title)
    }
    
}
