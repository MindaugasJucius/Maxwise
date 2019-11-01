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
                
                let formattedCreationDate = String.init(format: creationString, month, day)
                let customCreationDate = dateFormatter.date(from: formattedCreationDate)
                
                let expenseEntry = expense(
                    from: .init(title: "random \(month) \(day)",
                                category: randomCategory,
                                user: try! userModelController.currentUserOrCreate(),
                                place: nil,
                                amount: Double(randomAmount),
                                shareAmount: .full),
                    creationDate: customCreationDate!
                )

                persist(expenseEntry: expenseEntry) { _ in
                    
                }
            }
        }
    }
    
    private func expense(from expenseDTO: ExpenseDTO, creationDate: Date = Date()) -> ExpenseEntry {
        let expenseEntry = ExpenseEntry.init()
        
        expenseEntry.creationDate = creationDate
        expenseEntry.amount = expenseDTO.amount
        expenseEntry.category = expenseDTO.category
        expenseEntry.title = expenseDTO.title
        expenseEntry.place = expenseDTO.place
        expenseEntry.id = UUID.init().uuidString
        expenseEntry.sharePercentage = expenseDTO.shareAmount.rawValue

        let creationDateComponentsToStore = Set<Calendar.Component>(arrayLiteral: .year, .month, .day)
        let components = Calendar.current.dateComponents(creationDateComponentsToStore, from: creationDate)
        expenseEntry.month.value = components.month
        expenseEntry.day.value = components.day
        expenseEntry.year.value = components.year
        
        return expenseEntry
    }

    public func edit(expenseEntryID: String,
                     expenseDTO: ExpenseDTO,
                     completion: (Result<ExpenseEntry, CreationIssue>) -> ()) {
        guard let expenseEntry = expenseEntry(fromID: expenseEntryID) else {
            completion(.failure(.alert("Failed to find expense to edit")))
            return
        }
        
        do {
            let realm = try Realm.groupRealm()
            try realm.write {
                expenseEntry.amount = expenseDTO.amount
                expenseEntry.category = expenseDTO.category
                expenseEntry.title = expenseDTO.title
                realm.add(expenseEntry, update: .all)
            }
            completion(.success(expenseEntry))
        } catch let error {
            completion(.failure(.alert(error.localizedDescription)))
        }
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
    public func observeExpenseEntries(filterPredicate: NSPredicate?, updated: @escaping ([ExpenseEntry]) -> ()) {
        let realm = try? Realm.groupRealm()
        
        let results: Results<ExpenseEntry>?
        
        if let predicate = filterPredicate {
            results = realm?.objects(ExpenseEntry.self)
                            .filter(predicate)
        } else {
            results = realm?.objects(ExpenseEntry.self)
        }
        
        let expenseEntries = results?
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
        observeExpenseEntries(filterPredicate: nil) { entries in
            let yearMonthExpenseDates = entries
                .map { $0.creationDate }
                .map { Calendar.current.dateComponents(self.componentsToParseFromDate, from: $0) }
                .compactMap { Calendar.current.date(from: $0) }
            let dates = Array(Set(yearMonthExpenseDates)).sorted(by: <)
            updated((entries, dates))
        }
    }
    
    public func expenses(in date: Date, with dateComponents: Set<Calendar.Component>? = nil) -> [ExpenseEntry] {
        let allExpenses = retrieveAllExpenseEntries()
        return filter(expenses: allExpenses, by: date, with: dateComponents)
    }

    /// Returns expenses created in date matching .year, .month components
    /// - Parameter date: filtering happends based on this value
    public func filter(expenses: [ExpenseEntry], by date: Date, with dateComponents: Set<Calendar.Component>? = nil) -> [ExpenseEntry] {
        let components = dateComponents ?? componentsToParseFromDate
        
        let filterComponents = Calendar.dictionary(of: components, from: date)
        
        let expensesInDate = expenses.filter { entry in
            let expenseDateWithNecessaryComponents = Calendar.current.dateComponents(components, from: entry.creationDate)
            
            let matchingComponents = components.filter { (component) -> Bool in
                filterComponents[component] == expenseDateWithNecessaryComponents.value(for: component)
            }
            return matchingComponents.count == components.count
        }
        
        return expensesInDate
    }
    
    private func retrieveAllExpenseEntries() -> [ExpenseEntry] {
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

public extension Calendar {
    
    static func dictionary(of components: Set<Component>, from date: Date) -> [Component: Int?] {
        let dateComponentsToFilterBy = current.dateComponents(components, from: date)

        var filterComponents: [Component: Int?] = [:]
        components.forEach { component in
            filterComponents[component] = dateComponentsToFilterBy.value(for: component)
        }
        
        return filterComponents
    }
    
}
