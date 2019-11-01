import UIKit
import ExpenseKit
import Charts

struct ExpenseCategoryStatsDTO: Hashable {
    
    let amountSpentFormatted: String
    let amountSpentDouble: Double
    let percentageOfAmountInDateRange: Double
    let categoryTitle: String
    let categoryID: String
    let emojiValue: String
    let color: UIColor
    /// The most granular expense entry creation date component that this DTO is based upon
    let representationGranularity: Calendar.Component
    let representationDate: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(categoryID)
    }
}

class CategoriesStatisticsViewModel {

    private let statsQueue = DispatchQueue(label: "com.maxwise.stats.fetch.queue",
                                           qos: .userInteractive)

    private let currentYearFormat = "MMMM"
    private let previousYearsFormat = "MMM, yyyy"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    private let expenseModelController = ExpenseEntryModelController()
    
    lazy var categoriesListViewModel = CategoriesListViewModel(
        listSectionSelectionChanged: { [weak self] selectedSectionIndex in
            guard self?.currentSelectedIndex != selectedSectionIndex else {
                return
            }
            self?.currentSelectedIndex = selectedSectionIndex
            self?.invokeChartDataChangeForSelectionIndex()
            self?.updateDateRangeSelection?(selectedSectionIndex)
        }
    )

    lazy var categoriesChartsViewModel = CategoriesChartsViewModel(
        choseToFilterByDate: { [weak self] date in
            self?.filterListViewModel(by: date)
        },
        choseToResetFilter: { [weak self] in
            self?.resetListViewModelFilter()
        },
        choseToHighlightCategory: { [weak self] categoryID in
            guard let selectedIndex = self?.currentSelectedIndex else {
                return
            }

            self?.categoriesListViewModel.highlight(
                currentSelectedSection: selectedIndex,
                categoryID: categoryID
            )
        }
    )
    
    private var currentExpenseCreationDates: [Date] = []
    private var currentSelectedIndex: Int?

    private var currentStatsData = [(Date, [ExpenseCategoryStatsDTO])]()
    
    var updateDateRangeSelection: ((Int) -> ())?
    
    func observeDateRangeSelectionRepresentations(changed: @escaping ([String]) -> ()) {
        expenseModelController.expensesYearsMonths { [weak self] expenses, dates in
            guard let self = self else {
                return
            }
        
            changed(self.timeRangeSelectionRepresentations(from: dates))
            
            self.currentExpenseCreationDates = dates
            
            self.currentStatsData = dates.map { date in
                return (date, self.data(from: expenses, for: date))
            }
                                    
            // If there's nothing selected it means that we're loading data initially
            // Pre select the last item
            if self.currentSelectedIndex == nil {
                // When there are no expenses dates array is empty
                let preselectionIndex = max(dates.count - 1, 0)
                self.currentSelectedIndex = preselectionIndex
            }
            
            self.updateDateRangeSelection?(self.currentSelectedIndex!)
            
            self.categoriesListViewModel.updateList(
                with: self.currentStatsData,
                changeSelectionToIndex: self.currentSelectedIndex
            )
            
            self.invokeChartDataChangeForSelectionIndex()
        }
    }
    
    private func filterListViewModel(by date: Date) {
        guard let selectedIndex = currentSelectedIndex else {
            return
        }
        let expenses = expenseModelController.expenses(in: date, with: [.day, .month, .year])
        let expensesByCategoryInDate = expensesByCategory(expenses: expenses)
        
        let statsDTOs = expenseCategoryStatsDTOs(
            from: expensesByCategoryInDate,
            date: date,
            representationGranularity: .day
        )
        
        categoriesListViewModel.reload(currentSelectedSection: selectedIndex, with: statsDTOs)
    }
    
    private func resetListViewModelFilter() {
        categoriesListViewModel.updateList(with: currentStatsData)
    }
    
    private func data(from expenses: [ExpenseEntry],
                      for date: Date) -> [ExpenseCategoryStatsDTO] {
        let expensesInDate = expenseModelController.filter(expenses: expenses, by: date)
        let expensesByCategoryInDate = expensesByCategory(expenses: expensesInDate)
        
        let statsDTOs = expenseCategoryStatsDTOs(
            from: expensesByCategoryInDate,
            date: date,
            representationGranularity: .month
        )
        
        return statsDTOs
    }
    
    private func expensesByCategory(expenses: [ExpenseEntry]) ->  [ExpenseCategory: [ExpenseEntry]] {
        var categoryExpensesInDate = [ExpenseCategory: [ExpenseEntry]]()
        expenses.forEach { entry in
            guard let category = entry.category else {
                return
            }
            var expenses = categoryExpensesInDate[category] ?? []
            expenses.append(entry)
            categoryExpensesInDate[category] = expenses
        }
        return categoryExpensesInDate
    }

    // Cia kai date range pascrollini o nori atnaujint chartus :)
    func invokeChartDataChange(for selectionIndex: Int) {
        currentSelectedIndex = selectionIndex
        invokeChartDataChangeForSelectionIndex()
    }
    
    private func invokeChartDataChangeForSelectionIndex() {
        guard let currentSelectedIndex = self.currentSelectedIndex else {
            return
        }

        guard let date = currentExpenseCreationDates[safe: currentSelectedIndex],
            let categoryDTOs = currentStatsData.first(where: { $0.0 == date })?.1 else {
            // there's no stats data.
            categoriesChartsViewModel.clearCharts()
            return
        }

        categoriesChartsViewModel.update(for: date, categoryStatsDTOs: categoryDTOs)
    }

}

// MARK: - UI data mapping
extension CategoriesStatisticsViewModel {
    
    private func timeRangeSelectionRepresentations(from dates: [Date]) -> [String] {
        let representations = dates.map { date -> String in
            let comparisonResult = Calendar.current.compare(date, to: Date(), toGranularity: .year)
            let isPreviousYear = comparisonResult == .orderedAscending
            if isPreviousYear {
                self.dateFormatter.dateFormat = self.previousYearsFormat
            } else {
                self.dateFormatter.dateFormat = self.currentYearFormat
            }
            return self.dateFormatter.string(from: date)
        }
        return representations
    }
    
    private func expenseCategoryStatsDTOs(from categoriesExpenses: [ExpenseCategory: [ExpenseEntry]],
                                          date: Date,
                                          representationGranularity: Calendar.Component) -> [ExpenseCategoryStatsDTO] {
        let categoriesAndAmounts = categoriesExpenses.map { categoryWithExpenses -> (ExpenseCategory, Double) in
            let totalAmountSpentInCategory = categoryWithExpenses.value.reduce(0.0) { result, entry in
                result + entry.amount
            }
            return (categoryWithExpenses.key, totalAmountSpentInCategory)
        }

        let allAmount = categoriesAndAmounts.reduce(0.0, { $0 + $1.1 })
        
        let categoryStatsDTOs = categoriesAndAmounts.compactMap { (category, amountSpent) -> ExpenseCategoryStatsDTO? in
            let percentage = amountSpent / allAmount
            let numberAmountSpent = NSNumber.init(value: amountSpent)
            guard let color = category.color?.uiColor,
                let amountSpentCurrency = currencyFormatter.string(from: numberAmountSpent) else {
                return nil
            }

            return ExpenseCategoryStatsDTO(amountSpentFormatted: amountSpentCurrency,
                                           amountSpentDouble: amountSpent,
                                           percentageOfAmountInDateRange: percentage,
                                           categoryTitle: category.title,
                                           categoryID: category.id,
                                           emojiValue: category.emojiValue,
                                           color: color,
                                           representationGranularity: representationGranularity,
                                           representationDate: date)
        }.sorted { $0.amountSpentDouble > $1.amountSpentDouble }

        return categoryStatsDTOs
    }
    
}
