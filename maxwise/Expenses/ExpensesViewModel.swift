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
        return modelController.retrieveAllExpenseEntries().map { expenseEntry in
            var image: UIImage? = nil
            if let imageData = expenseEntry.imageData {
                let deserializedImage = UIImage(data: imageData)
                image = deserializedImage
            }
            
            print(expenseEntry.place?.title)
            
            return ExpensePresentationDTO(id: expenseEntry.id,
                                  currencyAmount: formatted(amount: expenseEntry.amount),
                                  title: expenseEntry.title,
                                  formattedDate: dateFormatter.string(from: expenseEntry.creationDate),
                                  image: image)
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
