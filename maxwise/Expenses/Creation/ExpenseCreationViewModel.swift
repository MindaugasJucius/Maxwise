import Foundation
import UIKit
import ExpenseKit

enum ValidationResult<T> {
    case success(T)
    case failure([CreationIssue])
}

class ExpenseCreationViewModel {
    
    private let maxAmount = 1000000.00
    
    private let expenseEntryModelController = ExpenseEntryModelController()
    private let userModelController = UserModelController()
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    
    var amountPlaceholder: String? {
        get {
            currencyFormatter.currencySymbol = ""
            let placeholder = currencyFormatter.string(from: NSNumber(value: 0))
            currencyFormatter.currencySymbol = NSLocale.current.currencySymbol
            return placeholder
        }
    }
    
    lazy var currencySymbol = currencyFormatter.currencySymbol
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private lazy var inputToDoubleFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private lazy var inputToDoubleFormatterNoGrouping: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    
    var categories: [ExpenseCategory] {
        return expenseCategoryModelController.storedCategories()
    }
    
    var percentages: [ExpenseDTO.SharePercentage] = [.full, .half]

    func entry(from id: String) -> ExpenseEntry? {
        return expenseEntryModelController.expenseEntry(fromID: id)
    }

    func formatExisting(input: Double) -> String? {
        let number = NSNumber.init(value: input)
        guard let string = inputToDoubleFormatterNoGrouping.string(from: number) else {
            return nil
        }
        
        return string
    }
    
    func performModelCreation(editedExpenseID: String?,
                              title: String?,
                              amount: String?,
                              selectedPlace: NearbyPlace?,
                              categoryID: String?,
                              result: (ValidationResult<Void>) -> ()) {
    
        let validationResult = validate(title: title,
                                        amount: amount,
                                        selectedPlace: selectedPlace,
                                        categoryID: categoryID,
                                        sharePercentage: .full)
        
        switch validationResult {
        case .failure(let issues):
            result(.failure(issues))
        case .success(let dto):
            let completionHandler: (Result<ExpenseEntry, CreationIssue>) -> () = { creationResult in
                switch creationResult {
                case .failure(let error):
                    result(.failure([error]))
                case .success(_):
                    result(.success(()))
                }
            }
            
            if let editedExpenseID = editedExpenseID {
                expenseEntryModelController.edit(expenseEntryID: editedExpenseID,
                                                 expenseDTO: dto,
                                                 completion: completionHandler)
            } else {
                expenseEntryModelController.create(expenseDTO: dto,
                                                   completion: completionHandler)
            }
        }
    }
    
    private func validate(title: String?,
                          amount: String?,
                          selectedPlace: NearbyPlace?,
                          categoryID: String?,
                          sharePercentage: ExpenseDTO.SharePercentage) -> ValidationResult<ExpenseDTO> {
        var issues: [CreationIssue] = []
        
        let filteredSelected = categories.filter { $0.id == categoryID }

        let category = retrieve(from: filteredSelected.first, issue: .noCategory, issues: &issues)
        
        let noUserCanBeCreated = CreationIssue.alert("User can't be created")
        let user = retrieve(from: try? userModelController.currentUserOrCreate(), issue: noUserCanBeCreated, issues: &issues)

        guard let expenseAmount = retrieve(from: amount, issue: .noAmount, issues: &issues) else {
            issues.append(.noAmount)
            return .failure(issues)
        }
        
        guard let formattedInput = inputToDoubleFormatter.number(from: expenseAmount), formattedInput.doubleValue > 0,
            formattedInput.doubleValue < maxAmount,
            currencyFormatter.string(from: formattedInput) != nil else {
            // Failed to format to a currency string - must be an invalid input
            issues.append(.noAmount)
            return .failure(issues)
        }
        
        guard let categoryValue = category, let userValue = user else {
            return .failure(issues)
        }

        let presentationTitle: String
        if let customTitle = title, !customTitle.isEmpty {
            presentationTitle = customTitle
        } else {
            presentationTitle = categoryValue.title
        }
        
        let expenseDTO = ExpenseDTO(title: presentationTitle,
                                    category: categoryValue,
                                    user: userValue,
                                    place: nil,
                                    amount: formattedInput.doubleValue,
                                    shareAmount: sharePercentage)
        return .success(expenseDTO)
    }
    
    private func retrieve<T>(from value: T?, issue: CreationIssue, issues: inout [CreationIssue]) -> T? {
        guard let value = value else {
            issues.append(issue)
            return nil
        }
        
        return value
    }
}
