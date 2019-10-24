import Foundation
import Charts
import ExpenseKit

class CategoriesChartsViewModel {
    
    private let expenseEntryModelController = ExpenseEntryModelController()
    
    var chartDataChanged: (([ChartData]) -> ())?
    
    func update(for date: Date, categoryStatsDTOs: [ExpenseCategoryStatsDTO]) {
        let pieChartData = constructPieChartData(from: categoryStatsDTOs)
        let lineChartData = constructLineChartData(from: expenses(in: date))
        chartDataChanged?([pieChartData, lineChartData])
    }
    
    private func expenses(in date: Date) -> [ExpenseEntry] {
        let allExpenses = expenseEntryModelController.retrieveAllExpenseEntries()
        return expenseEntryModelController.filter(expenses: allExpenses, by: date)
    }
    
    private func constructLineChartData(from expenseEntries: [ExpenseEntry]) -> LineChartData {
        var expenseAmountInDays = [Int: Double]()
        expenseEntries.forEach { entry in
            guard let day = Calendar.current.dateComponents([.day], from: entry.creationDate).day else {
                return
            }
            let currentAmountInDay = expenseAmountInDays[day] ?? 0.0
            expenseAmountInDays[day] = currentAmountInDay + entry.amount
        }
        
        let chartEntries = expenseAmountInDays.map { (day, amount) in
            return ChartDataEntry(x: Double(day), y: amount)
        }

        let set1 = LineChartDataSet(entries: chartEntries.sorted { $0.x < $1.x }, label: nil)
        set1.drawIconsEnabled = false

        set1.lineWidth = 3
        set1.drawValuesEnabled = false
        set1.mode = .linear
        set1.drawCirclesEnabled = true
        set1.drawFilledEnabled = true
        set1.fillAlpha = 1
        set1.circleHoleRadius = 3
        set1.circleRadius = 6

        setColor(for: set1)
        return LineChartData(dataSet: set1)
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
                              backgroundColor?.withAlphaComponent(0.2).cgColor]

        
        if let gradient = CGGradient(colorsSpace: nil,
                                     colors: gradientColors as CFArray,
                                     locations: [0.8, 1]) {
            dataSet.fill = Fill(linearGradient: gradient, angle: -90)
        }
        dataSet.drawVerticalHighlightIndicatorEnabled = false
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
