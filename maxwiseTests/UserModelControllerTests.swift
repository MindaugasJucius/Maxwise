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

}
