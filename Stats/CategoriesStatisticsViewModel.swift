import UIKit
import ExpenseKit
import Charts

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
    
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    private let expenseModelController = ExpenseEntryModelController()
    
    private var currentExpenseCreationDates: [Date] = [] {
        didSet {
            // If there's nothing selected it means that we're loading data initially
            // Pre select the last item
            if self.currentSelectedIndex == nil {
                let preselectionIndex = currentExpenseCreationDates.count - 1
                self.currentSelectedIndex = preselectionIndex
                shouldUpdateSelection?(preselectionIndex)
            }
        }
    }
    private var currentSelectedIndex: Int?

    typealias StatsData = (categories: [ExpenseCategory], chartData: PieChartData)
    
    var categoriesForSelection: ((StatsData) -> ())?
    var shouldUpdateSelection: ((Int) -> ())?
    
    func selected(index: Int) {
        guard let date = currentExpenseCreationDates[safe: index] else {
            return
        }
        currentSelectedIndex = index
        let allData = data(for: date)
        categoriesForSelection?(allData)
    }
    
    func observeDateRangeSelectionRepresentations(changed: @escaping ([String]) -> ()) {
        expenseModelController.expensesYearsMonths { [weak self] dates in
            guard let self = self else {
                return
            }
        
            changed(self.timeRangeSelectionRepresentations(from: dates))
            
            self.currentExpenseCreationDates = dates

            // Update data for current selection when changes occur
            guard let currentSelectedIndex = self.currentSelectedIndex else {
                return
            }
            self.selected(index: currentSelectedIndex)
        }
    }
    
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
    
    private func data(for date: Date) -> StatsData {
        let expensesInDate = expenseModelController.expenses(in: date)
        let expenseCategories = Array(Set(expensesInDate.compactMap { $0.category }))
        let pieChartData = constructPieChartData(from: expenseCategories)
        return (expenseCategories, pieChartData)
    }
    
    private func constructPieChartData(from categories: [ExpenseCategory]) -> PieChartData {
        let titlesAndAmounts = categories.map { category -> (String, Double) in
            let totalAmountSpentInCategory = category.expenses.reduce(0.0) { result, entry in
                result + entry.amount
            }
            return (category.title, totalAmountSpentInCategory)
        }

        let dataEntries = titlesAndAmounts.map {
            PieChartDataEntry.init(value: $0.1, label: $0.0)
        }

        let dataSet = PieChartDataSet(entries: dataEntries, label: nil)
        dataSet.colors = categories.compactMap { $0.color?.uiColor }
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
