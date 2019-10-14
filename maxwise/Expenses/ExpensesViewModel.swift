import UIKit
import ExpenseKit

struct ExpensePresentationDTO: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let currencyAmount: String
    let sharePercentageCurrencyAmount: String
    let title: String
    let categoryColor: UIColor?
    let categoryEmojiValue: String
    let formattedDate: String
    let image: UIImage?

}

typealias GroupedExpenses = [(Date, [ExpensePresentationDTO])]

class ExpensesViewModel {
    
    private let modelController = ExpenseEntryModelController()
    private let userModelController = UserModelController()
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
    
    private lazy var expenseGroupDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    var toggleNoExpensesView: ((Bool) -> ())?
    
    func observeExpenseEntries(changeOccured: @escaping (GroupedExpenses) -> Void) {
        modelController.observeExpenseEntries { [weak self] expenseEntries in
            guard let self = self else {
                return
            }

            let showNoExpensesView = expenseEntries.count == 0
            self.toggleNoExpensesView?(showNoExpensesView)
            
            changeOccured(self.groupedByDay(expenses: expenseEntries))
        }
    }
    
    func expenseGroupSectionDescription(from date: Date) -> String {
        let comparisonResult = Calendar.current.compare(date, to: Date(), toGranularity: .year)
        let isPreviousYear = comparisonResult == .orderedAscending
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else if isPreviousYear {
            expenseGroupDateFormatter.dateFormat = "MMMM d, yyyy"
            return expenseGroupDateFormatter.string(from: date)
        } else {
            expenseGroupDateFormatter.dateFormat = "MMMM d"
            return expenseGroupDateFormatter.string(from: date)
        }
    }
    
    private func dto(from expenseEntry: ExpenseEntry) -> ExpensePresentationDTO {
        var image: UIImage? = nil
        if let imageData = expenseEntry.imageData {
            let deserializedImage = UIImage(data: imageData)
            image = deserializedImage
        }

        guard let category = expenseEntry.category else {
            fatalError()
        }

        let shareAmount = expenseEntry.amount * expenseEntry.sharePercentage
        
        return ExpensePresentationDTO(id: expenseEntry.id,
                                      currencyAmount: formatted(amount: expenseEntry.amount),
                                      sharePercentageCurrencyAmount: formatted(amount: shareAmount),
                                      title: expenseEntry.title,
                                      categoryColor: category.color?.uiColor,
                                      categoryEmojiValue: category.emojiValue,
                                      formattedDate: dateFormatter.string(from: expenseEntry.creationDate),
                                      image: image)
    }
    
    func delete(expense: ExpensePresentationDTO, completion: (Result<Void, Error>) -> ()) {
        modelController.delete(expenseWithID: expense.id, deleted: completion)
    }
    
    func groupedByDay(expenses: [ExpenseEntry]) -> GroupedExpenses {
        let dictionary = [Date: [ExpensePresentationDTO]]()
        let components = Set<Calendar.Component>(arrayLiteral: .year, .month, .weekOfMonth, .weekday)
        return expenses.reduce(into: dictionary) { [weak self] (result, entry) in
            guard let self = self else {
                return
            }
            
            let components = Calendar.current.dateComponents(components, from: entry.creationDate)
            guard let dateFromComponents = Calendar.current.date(from: components) else {
                return
            }
            let existing = result[dateFromComponents] ?? []
            result[dateFromComponents] = existing + [self.dto(from: entry)]
        }.sorted { (tuple1, tuple2) in
            return tuple1.key > tuple2.key
        }
    }
    
    private func formatted(amount: Double) -> String {
        let amountNumber = NSNumber(value: amount)
        let formattedAmount = currencyFormatter.string(from: amountNumber) ?? "😬"
        return formattedAmount
    }
    
}
