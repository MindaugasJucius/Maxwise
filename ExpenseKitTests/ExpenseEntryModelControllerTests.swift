import XCTest
import RealmSwift
import ExpenseKit
@testable import maxwise

class ExpenseEntryModelControllerTests: XCTestCase {

    typealias YearMonth = (year: Int, month: Int)
    
    override func setUp() {
        TestsHelper.clearRealm()
    }
    
    func testCreateExpenseReturnsYearMonthMatchingSection() {
        let expectation = XCTestExpectation(description: "distinct expense creation dates fetched")
        
        let date = Date()
        let components = getYearMonth(from: date)
        
        let expenseEntryModelController = ExpenseEntryModelController()
        let userModelController = UserModelController()
        let currentUser = try! userModelController.currentUserOrCreate()
        
        TestsHelper.createExpense(user: currentUser, amount: 0, title: "test expense") { result in
            switch result {
            case .failure(let issue):
                XCTFail(issue.localizedDescription)
            case .success(_) :
                expenseEntryModelController.expensesYearsMonths { dates in
                    let firstDate = dates.first!
                    let entryComponents = self.getYearMonth(from: firstDate)
                    XCTAssert(components.year == entryComponents.year
                        && components.month == components.month)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testCreateMultipleExpensesWithRepeatingDatesReturnsCorrectCountOfDistinctDates() {
        let expectation = XCTestExpectation(description: "correct count of dates fetched")
        
        let dateStringsToTest = ["2019 09 03", "2019 09 01", "2019 09 05",
                                 "2017 09 15",
                                 "2016 09 08",
                                 "2024 10 29"]
        let datesToTest = dates(from: dateStringsToTest)
        let entries = datesToTest.map(expense(from:))
        
        let realm = try! Realm.groupRealm()
        try! realm.write {
            realm.add(entries)
        }
        
        let expenseEntryModelController = ExpenseEntryModelController()
        expenseEntryModelController.expensesYearsMonths { dates in
            XCTAssert(dates.count == 4)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
    
    func testFilteringExpensesByYearAndMonthReturnsExpensesWithMatchingCreationDates() {
        let dateStringMatch = "2019 05 18"
        let dateStringToFilter = dateStringMatch
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        guard let filterDate = dateFormatter.date(from: dateStringToFilter) else {
            XCTFail()
            return
        }
        
        let expenseCreationDateStrings = [
            dateStringMatch, //
            "2016 09 18",
            "2019 05 10", //
            "2019 05 16", //
            "2019 04 30",
            "2019 01 18"
        ]

        let datesToTest = dates(from: expenseCreationDateStrings)
        let entries = datesToTest.map(expense(from:))
        
        let realm = try! Realm.groupRealm()
        try! realm.write {
            realm.add(entries)
        }
        
        let expenseEntryModelController = ExpenseEntryModelController()
        XCTAssert(expenseEntryModelController.expenses(in: filterDate).count == 3)
    }

    func dates(from strings: [String]) -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        let dates = strings.compactMap { dateFormatter.date(from: $0) }
        XCTAssert(strings.count == dates.count)
        return dates
    }
    
    func expense(from date: Date) -> ExpenseEntry {
        let entry = ExpenseEntry()
        entry.id = NSUUID().uuidString
        entry.creationDate = date
        let category = ExpenseCategory()
        category.id = NSUUID().uuidString
        entry.category = category
        return entry
    }
    
    func getYearMonth(from date: Date) -> YearMonth {
        let componentsToGet = Set<Calendar.Component>(arrayLiteral: .year, .month)
        let components = Calendar.current.dateComponents(componentsToGet, from: date)
        return (components.year!, components.month!)
    }

}
