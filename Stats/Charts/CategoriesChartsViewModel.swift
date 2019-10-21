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
        let chartEntries = expenseEntries.compactMap { entry -> ChartDataEntry? in
            guard let day = Calendar.current.dateComponents([.day], from: entry.creationDate).day else {
                return nil
            }

            return ChartDataEntry.init(x: Double(day), y: entry.amount)
        }
        
        let set1 = LineChartDataSet.init(entries: chartEntries, label: nil)
        set1.drawIconsEnabled = false
        
//        set1.lineDashLengths = [5, 2.5]
//        set1.highlightLineDashLengths = [5, 2.5]
        set1.setColor(.black)
        set1.lineWidth = 1
        set1.valueFont = .systemFont(ofSize: 9)
//        set1.formLineDashLengths = [5, 2.5]
        set1.formLineWidth = 1
        set1.formSize = 15
        set1.mode = .horizontalBezier
        set1.drawCirclesEnabled = false
        
        
//        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
//                              ChartColorTemplates.colorFromString("#ffff0000").cgColor]
//        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
//
        set1.fillAlpha = 1
        //set1.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        set1.drawFilledEnabled = true
        
        return LineChartData(dataSet: set1)
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
