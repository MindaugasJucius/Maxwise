import Foundation
import Charts
import ExpenseKit

struct FormattedLineChartEntry {
    let monthDayRepresentation: String
    let totalAmountSpent: String
    let fullEntryDate: Date
}

struct FormattedPieChartEntry {
    let categoryID: String
}

class CategoriesChartsViewModel {
    
    private let expenseEntryModelController = ExpenseEntryModelController()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    var chartDataChanged: (([ChartData]?) -> ())?
    
    let choseToFilterByDate: (Date) -> ()
    let choseToResetFilter: () -> ()

    let choseToHighlightCategory: (String) -> ()
    
    init(choseToFilterByDate: @escaping (Date) -> (),
         choseToResetFilter: @escaping () -> (),
         choseToHighlightCategory: @escaping (String) -> ()) {
        self.choseToFilterByDate = choseToFilterByDate
        self.choseToResetFilter = choseToResetFilter
        self.choseToHighlightCategory = choseToHighlightCategory
    }
    
    func clearCharts() {
        chartDataChanged?(nil)
    }
    
    func update(for date: Date, categoryStatsDTOs: [ExpenseCategoryStatsDTO]) {
        let pieChartData = constructPieChartData(from: categoryStatsDTOs)
        let lineChartData = constructLineChartData(from: expenseEntryModelController.expenses(in: date))
        chartDataChanged?([pieChartData, lineChartData])
    }
        
    private func lineChartEntries(from expenseEntries: [ExpenseEntry]) -> [ChartDataEntry] {
        var expenseAmountInDateDayMonth = [Date: Double]()
        
        expenseEntries.forEach { entry in
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: entry.creationDate)
            guard let date = Calendar.current.date(from: dateComponents) else {
                return
            }

            let currentAmountInDay = expenseAmountInDateDayMonth[date] ?? 0
            expenseAmountInDateDayMonth[date] = currentAmountInDay + entry.amount
        }
        
        let sortedExpenseAmountInDayMonth = expenseAmountInDateDayMonth.sorted { (keyValuePair1, keyValuePair2) -> Bool in
            return keyValuePair1.key < keyValuePair2.key
        }
        
        
        // Chart should show ever increasing amount (each step is: previous days + current)
        var totalCurrentAmount: Double = 0
        
        let chartEntries = sortedExpenseAmountInDayMonth.compactMap { (date, amount) -> ChartDataEntry? in
            let dayComponent = Calendar.current.dateComponents([.day], from: date)
            guard let day = dayComponent.day else {
                return nil
            }

            guard let formattedAmount = currencyFormatter.string(from: NSNumber(value: amount)) else {
                return nil
            }
            
            let formattedEntry = FormattedLineChartEntry.init(
                monthDayRepresentation: dateFormatter.string(from: date),
                totalAmountSpent: formattedAmount,
                fullEntryDate: date
            )
            
            totalCurrentAmount += amount
            
            return ChartDataEntry(x: Double(day), y: totalCurrentAmount, data: formattedEntry)
        }
        
        return chartEntries
    }

    private func constructLineChartData(from expenseEntries: [ExpenseEntry]) -> LineChartData {
        let chartEntries = lineChartEntries(from: expenseEntries)
        
        let mainDataSet = constructDataSet(from: chartEntries)

        let chartData = LineChartData(dataSet: mainDataSet)
        
        // To workaround showing one circle lets add a placeholder data set
        if chartEntries.count == 1 {
            var emptyDataEntry = [ChartDataEntry.init(x: 0, y: 0, data: nil)]
            emptyDataEntry.append(contentsOf: chartEntries)
            let placeholderDataSet = constructDataSet(from: emptyDataEntry)
            placeholderDataSet.drawCirclesEnabled = false
            
            chartData.addDataSet(placeholderDataSet)
        }

        return chartData
    }

    private func constructDataSet(from entries: [ChartDataEntry]) -> LineChartDataSet {
        let dataSet = LineChartDataSet(entries: entries.sorted { $0.x < $1.x }, label: nil)
        dataSet.drawIconsEnabled = false

        dataSet.lineWidth = 3
        dataSet.drawValuesEnabled = false
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = true
        dataSet.drawFilledEnabled = true
        dataSet.fillAlpha = 1
        dataSet.circleHoleRadius = 3
        dataSet.circleRadius = 6

        dataSet.drawVerticalHighlightIndicatorEnabled = false
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        
        setColor(for: dataSet)
        return dataSet
    }
    
    private func setColor(for dataSet: LineChartDataSet) {
        guard let tintColor = UIColor.tintColor else {
            return
        }
        
        let backgroundColor = UIColor.init(named: "background")
        
        dataSet.setCircleColor(tintColor)
        dataSet.setColor(tintColor)
        
        dataSet.circleHoleColor = backgroundColor
        
        let gradientColors = [tintColor.withAlphaComponent(0.2).cgColor,
                              tintColor.withAlphaComponent(0.1).cgColor,
                              tintColor.withAlphaComponent(0.01).cgColor]

        
        if let gradient = CGGradient(colorsSpace: nil,
                                     colors: gradientColors as CFArray,
                                     locations: [0.6, 0.8, 1]) {
            dataSet.fill = Fill(linearGradient: gradient, angle: -90)
        }
    }
    
    private func constructPieChartData(from dtos: [ExpenseCategoryStatsDTO]) -> PieChartData {
        let dataEntries = dtos.map { dto -> PieChartDataEntry in
            let pieChartEntryData = FormattedPieChartEntry(categoryID: dto.categoryID)
            return PieChartDataEntry.init(value: dto.amountSpentDouble, label: dto.categoryTitle, data: pieChartEntryData)
        }

        let dataSet = PieChartDataSet(entries: dataEntries, label: nil)
        dataSet.colors = dtos.compactMap { $0.color }
        dataSet.automaticallyDisableSliceSpacing = true
        dataSet.yValuePosition = .outsideSlice
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueLineColor = .label
        dataSet.valueLineWidth = 1.5
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .medium)
        dataSet.drawValuesEnabled = true
        dataSet.valueFormatter = Formatter()
        dataSet.entryLabelColor = .label
        dataSet.sliceSpace = 3
        let data = PieChartData(dataSet: dataSet)
        data.setValueTextColor(.label)
        
        return data
    }
    
}

private class Formatter: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "\(Int(round(value)))%"
    }
    
}
