import UIKit

struct ExpensePresentationDTO {
    let id: String
    let currencyAmount: String
    let title: String
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
    
    var amountSpentChanged: ((Double) -> ())? {
        didSet {
            beginObservingAmountChanges()
        }
    }
        
    func expenseEntries() -> [ExpensePresentationDTO] {
        return modelController.retrieveAllExpenseEntries().map { dto in
            let amountNumber = NSNumber(value: dto.amount)
            let amount = currencyFormatter.string(from: amountNumber) ?? "😬"
            return ExpensePresentationDTO(id: dto.id,
                                          currencyAmount: amount,
                                          title: dto.title,
                                          formattedDate: dateFormatter.string(from: dto.date),
                                          image: dto.image)
        }
    }
    
    private func beginObservingAmountChanges() {
        guard let currentUser = try? userModelController.currentUserOrCreate(),
            let observationBlock = amountSpentChanged else {
            return
        }
        
        userModelController.observeAmountSpent(forUser: currentUser,
                                               amountChanged: observationBlock)
    }
    
}
