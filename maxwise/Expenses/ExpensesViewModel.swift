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
    
    var amountSpentChanged: ((String) -> ())? {
        didSet {
            beginObservingAmountChanges()
        }
    }
        
    func expenseEntries() -> [ExpensePresentationDTO] {
        return modelController.retrieveAllExpenseEntries().map { dto in
            return ExpensePresentationDTO(id: dto.id,
                                  currencyAmount: formatted(amount: dto.amount),
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
