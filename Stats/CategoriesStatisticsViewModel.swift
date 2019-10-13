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
            self?.shouldUpdateSelection?(selectedSectionIndex)
        }
    )
    
    private var currentExpenseCreationDates: [Date] = []
    private var currentSelectedIndex: Int?

    typealias StatsData = (categories: [ExpenseCategoryStatsDTO], chartData: PieChartData)
    
    private var currentStatsData = [(Date, StatsData)]()
    
    var shouldUpdateSelection: ((Int) -> ())?
    
    var selectedCategoryChartData: ((PieChartData) -> ())?
    
    func chartDataForSelectedCategory(at index: Int) -> PieChartData? {
        currentSelectedIndex = index
        guard let date = currentExpenseCreationDates[safe: index] else {
            return .none
        }

        return currentStatsData.first(where: { $0.0 == date })?.1.chartData
    }
    
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
            
            self.categoriesListViewModel.updateList(with: self.currentStatsData.map { ($0, $1.categories) })
            
            // If there's nothing selected it means that we're loading data initially
            // Pre select the last item
            if self.currentSelectedIndex == nil {
                let preselectionIndex = dates.count - 1
                self.currentSelectedIndex = preselectionIndex
                self.shouldUpdateSelection?(preselectionIndex)
            }

            self.invokeChartDataChangeForSelectionIndex()
        }
    }
    
    private func data(from expenses: [ExpenseEntry], for date: Date) -> StatsData {
        let expensesInDate = expenseModelController.filter(expenses: expenses, by: date)

        var categoryExpensesInDate = [ExpenseCategory: [ExpenseEntry]]()
        expensesInDate.forEach { entry in
            guard let category = entry.category else {
                return
            }
            var expenses = categoryExpensesInDate[category] ?? []
            expenses.append(entry)
            categoryExpensesInDate[category] = expenses
        }
        
        let statsDTOs = expenseCategoryStatsDTOs(from: categoryExpensesInDate)
        
        let pieChartData = constructPieChartData(from: statsDTOs)
        return (statsDTOs, pieChartData)
    }
    
    private func invokeChartDataChangeForSelectionIndex() {
        guard let currentSelectedIndex = self.currentSelectedIndex,
            let chartData = self.chartDataForSelectedCategory(at: currentSelectedIndex) else {
            return
        }

        self.selectedCategoryChartData?(chartData)
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
    
    private func expenseCategoryStatsDTOs(from categoriesExpenses: [ExpenseCategory: [ExpenseEntry]]) -> [ExpenseCategoryStatsDTO] {
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
                                           color: color)
        }.sorted { $0.amountSpentDouble > $1.amountSpentDouble }

        return categoryStatsDTOs
    }
    
    private func constructPieChartData(from dtos: [ExpenseCategoryStatsDTO]) -> PieChartData {
        let dataEntries = dtos.map {
            PieChartDataEntry.init(value: $0.amountSpentDouble, label: $0.categoryTitle)
        }

        let dataSet = PieChartDataSet(entries: dataEntries, label: nil)
        dataSet.colors = dtos.compactMap { $0.color }
        dataSet.automaticallyDisableSliceSpacing = true
        dataSet.yValuePosition = .outsideSlice
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueLineColor = .label
        dataSet.drawValuesEnabled = false
        dataSet.entryLabelColor = .label
        dataSet.sliceSpace = 3
        let data = PieChartData(dataSet: dataSet)
        data.setValueTextColor(.label)
        
        return data
    }
    
}
