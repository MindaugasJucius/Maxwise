import UIKit
import ExpenseKit

struct ExpensePresentationDTO: Hashable {
    let id: String
    let currencyAmount: String
    let title: String
    let categoryTitle: String
    let categoryColor: UIColor?
    let formattedDate: String
    let image: UIImage?
}

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
        formatter.dateFormat = "yyyy-MM-dd hh:mm"
        return formatter
    }()
    
    var amountSpentChanged: ((String) -> ())? {
        didSet {
            beginObservingAmountChanges()
        }
    }
    
    func observeExpenseEntries(changeOccured: @escaping ([Date: [ExpensePresentationDTO]]) -> Void) {
        modelController.observeExpenseEntries { [weak self] expenseEntries in
            guard let self = self else {
                return
            }

            changeOccured(self.groupedByWeek(expenses: expenseEntries))
        }
    }
    
    private func dto(from expenseEntry: ExpenseEntry) -> ExpensePresentationDTO {
        var image: UIImage? = nil
        if let imageData = expenseEntry.imageData {
            let deserializedImage = UIImage(data: imageData)
            image = deserializedImage
        }
        
//        if let place = expenseEntry.place {
//            locationInfo = "\(place.title), \(place.categoryTitle)"
//        }
        
        guard let category = expenseEntry.category else {
            fatalError()
        }

        
        return ExpensePresentationDTO(id: expenseEntry.id,
                                      currencyAmount: formatted(amount: expenseEntry.amount),
                                      title: expenseEntry.title,
                                      categoryTitle: category.title,
                                      categoryColor: category.color,
                                      formattedDate: dateFormatter.string(from: expenseEntry.creationDate),
                                      image: image)
    }
    
    private func groupedByWeek(expenses: [ExpenseEntry]) -> [Date: [ExpensePresentationDTO]] {
        let dictionary = [Date: [ExpensePresentationDTO]]()
        let components = Set<Calendar.Component>(arrayLiteral: .year, .month, .weekOfMonth)
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
        }
    }
    
    private func beginObservingAmountChanges() {
        guard let currentUser = try? userModelController.currentUserOrCreate(),
            let observationBlock = amountSpentChanged else {
            return
        }
        userModelController.observeAmountSpent(forUser: currentUser) { [weak self] amount in
            guard let self = self else {
                return
            }
            observationBlock(self.formatted(amount: amount))
        }
    }
    
    private func formatted(amount: Double) -> String {
        let amountNumber = NSNumber(value: amount)
        let formattedAmount = currencyFormatter.string(from: amountNumber) ?? "😬"
        return formattedAmount
    }
    
}
