import RealmSwift
import Intents

public enum CreationIssue: Error {
    case noAmount
    case noCategory
    case alert(String)
}

public enum DeletionIssue: Error {
    case failedToFindCategory
}

public class ExpenseEntryModelController {

    private var expenseEntryObservationTokens = [NotificationToken?]()
    
    
    public init() {
        
    }
    
    /// Create multiple expenses for debugging purpose
    /// - Parameter amount: range of created expense amount
    /// - Parameter monthRange: expense creation date month range
    /// - Parameter dayRange: expense creation date day range
    public func createRandomExpenses(amount: ClosedRange<Int>, monthRange: ClosedRange<Int>, dayRange: ClosedRange<Int>) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        
        let creationString = "2019 %d %d"

        let userModelController = UserModelController()
        let categoryModelController = ExpenseCategoryModelController()
        let storedCategories = categoryModelController.storedCategories()
        
        for month in monthRange {
            for day in dayRange {
                guard let randomCategory = storedCategories.randomElement(),
                    let randomAmount = amount.randomElement() else {
                    fatalError()
                }
                let expenseEntry = expense(
                    from: .init(title: "random \(month) \(day)",
                                category: randomCategory,
                                user: try! userModelController.currentUserOrCreate(),
                                place: nil,
                                amount: Double(randomAmount),
                                shareAmount: .full)
                )
                let formattedCreationDate = String.init(format: creationString, month, day)
                expenseEntry.creationDate = dateFormatter.date(from: formattedCreationDate)!
                persist(expenseEntry: expenseEntry) { _ in
                    
                }
            }
        }
    }
    

    private func expense(from expenseDTO: ExpenseDTO) -> ExpenseEntry {
        let expenseEntry = ExpenseEntry.init()
        expenseEntry.amount = expenseDTO.amount
        expenseEntry.category = expenseDTO.category
        expenseEntry.title = expenseDTO.title
        expenseEntry.place = expenseDTO.place
        expenseEntry.id = UUID.init().uuidString
        expenseEntry.sharePercentage = expenseDTO.shareAmount.rawValue
        return expenseEntry
    }
    
    public func create(expenseDTO: ExpenseDTO,
                       completion: (Result<ExpenseEntry, CreationIssue>) -> ()) {
        let expenseEntry = expense(from: expenseDTO)
        persist(expenseEntry: expenseEntry, completion: completion)
    }
    
    private func persist(expenseEntry: ExpenseEntry,
                         completion: (Result<ExpenseEntry, CreationIssue>) -> ()) {
        do {
            let realm = try Realm.groupRealm()
            try realm.write {
                realm.add(expenseEntry, update: .all)
                expenseEntry.owners.forEach {
                    $0.entries.append(expenseEntry)
                }
            }
            donateCreateExpense(expense: expenseEntry)
            completion(.success(expenseEntry))
        } catch let error {
            completion(.failure(.alert(error.localizedDescription)))
        }
    }
    
    public func expenseEntry(fromID id: String) -> ExpenseEntry? {
        do {
            let realm = try Realm.groupRealm()
            return realm.object(ofType: ExpenseEntry.self, forPrimaryKey: id)
        } catch {
            return nil
        }
    }
    
    public func delete(expenseWithID id: String, deleted: (Result<Void, Error>) -> ()) {
        do {
            let realm = try Realm.groupRealm()
            try realm.write {
                guard let object = realm.object(ofType: ExpenseEntry.self, forPrimaryKey: id) else {
                    deleted(.failure(DeletionIssue.failedToFindCategory))
                    return
                }
                realm.delete(object)
                deleted(.success(()))
            }
        } catch let error {
            deleted(.failure(error))
        }
    }

    // Can only observe on a thread with a run loop (main loop).
    // Adding run loops to custom threads: https://academy.realm.io/posts/realm-notifications-on-background-threads-with-swift/
    public func observeExpenseEntries(updated: @escaping ([ExpenseEntry]) -> ()) {
        let realm = try? Realm.groupRealm()
        let expenseEntries = realm?.objects(ExpenseEntry.self)
            .sorted(byKeyPath: "creationDate", ascending: false)
        let observationToken = expenseEntries?.observe { change in
            switch change {
            case .initial(let value):
                updated(Array(value))
            case .update(let value, deletions: _, insertions: _, modifications: _):
                updated(Array(value))
            default:
                print("huh")
            }
        }
        expenseEntryObservationTokens.append(observationToken)
    }
    
    let componentsToParseFromDate = Set<Calendar.Component>(arrayLiteral: .year, .month)
    
    /// Returns distinct expense creation [Date]s that consist only of year and month.
    public func expensesYearsMonths(updated: @escaping (([ExpenseEntry], [Date])) -> ()) {
        observeExpenseEntries { entries in
            let yearMonthExpenseDates = entries
                .map { $0.creationDate }
                .map { Calendar.current.dateComponents(self.componentsToParseFromDate, from: $0) }
                .compactMap { Calendar.current.date(from: $0) }
            let dates = Array(Set(yearMonthExpenseDates)).sorted(by: <)
            updated((entries, dates))
        }
    }

    /// Returns expenses created in date matching .year, .month components
    /// - Parameter date: filtering happends based on this value
    public func filter(expenses: [ExpenseEntry], by date: Date) -> [ExpenseEntry] {
        let filterYearMonth = Calendar.current.dateComponents(componentsToParseFromDate, from: date)
        guard let filterMonthIndex = filterYearMonth.month,
            let filterYear = filterYearMonth.year else {
            return []
        }
        
        let expensesInDate = expenses.filter { entry in
            let expenseYearMonth = Calendar.current.dateComponents(componentsToParseFromDate, from: entry.creationDate)
            guard let expenseMonthIndex = expenseYearMonth.month,
                let expenseYear = expenseYearMonth.year else {
                return false
            }
            return expenseMonthIndex == filterMonthIndex && expenseYear == filterYear
        }
        
        return expensesInDate
    }
    
    public func retrieveAllExpenseEntries() -> [ExpenseEntry] {
        guard let realm = try? Realm.groupRealm() else {
            return []
        }
        let arrayEntries = Array(realm.objects(ExpenseEntry.self))
        
        return arrayEntries
    }
    
    public func donateCreateExpense(expense: ExpenseEntry) {
        guard let currencyCode = Locale.current.currencyCode else {
            return
        }
        let intent = CreateExpenseIntent()

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.identifier = expense.id
        
        interaction.donate { error in
            print(error?.localizedDescription)
        }
    }

}
