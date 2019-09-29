import UIKit
import ExpenseKit
import Charts

class CategoriesStatisticsViewModel {

    private let statsQueue = DispatchQueue(label: "com.maxwise.stats.fetch.queue",
                                           qos: .userInteractive)
    
    private let currentYearFormat = "MMMM"
    private let previousYearsFormat = "yyyy MMMM"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()
    
    private let expenseCategoryModelController = ExpenseCategoryModelController()
    private let expenseModelController = ExpenseEntryModelController()
    
    func observeCategoryTotals(completion: @escaping (PieChartData) -> ()) {
        // Can only observe on a thread with a run loop (main loop).
        // Adding run loops to custom threads: https://academy.realm.io/posts/realm-notifications-on-background-threads-with-swift/
        self.expenseCategoryModelController.observeExpenseCategoryChanges { categories in
            self.statsQueue.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    completion(self.constructPieChartData(from: categories))
                }
            }
        }
    }
    
    func timeRangeSelectionRepresentations(changed: @escaping ([String]) -> ()) {
        expenseModelController.expensesYearsMonths { [weak self] dates in
            guard let self = self else {
                return
            }
            
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
            changed(representations)
        }
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
