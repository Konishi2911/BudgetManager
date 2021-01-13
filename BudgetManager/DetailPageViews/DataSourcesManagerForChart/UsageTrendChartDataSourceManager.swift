//
//  BarChartDataSourceManager.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/07.
//

import Cocoa
import BudgetCoreDatabase

public struct UsageTrendChartDataSourceManager {
    enum Components {
        case income
        case outlay
    }
    
    var targetPeriodUnit: DateOffsetter.PeriodUnit = .year
    var dataComponents: [Components] = [.income, .outlay]
    var refDate: Date = Date()
        
    mutating func offsetDate(_ offset: Int) {
        let offsetter = DateOffsetter(dateComponent: self.targetPeriodUnit)
        self.refDate = offsetter.offset(from: self.refDate, value: offset)!
        
        let formatter = DateFormatter.init()
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        let string = formatter.string(from: self.refDate)
        print(string)
    }
    mutating func setToToday() {
        self.refDate = Date()
    }
    
    func dataSource() -> BarChartDataSource? {
        let targetPeriod = TargetDateIntervalProvider(
            period: self.targetPeriodUnit, refDate: self.refDate
        ).targetPeriod
        let detailDataContainer = DataContainerForChart(period: targetPeriod)
        
        let detailContainer = detailDataContainer.getDetailDataContainer(
            unitPeriod: Self.unitPeriod(period: self.targetPeriodUnit)
        )
        
        var chartDataArray = [BarChartData]()
        for comp in self.dataComponents {
            switch comp {
            case .income:
                let inc = detailContainer.incomeByUnit.totalAmounts
                chartDataArray.append(
                    BarChartData(groupName: "Income", values: inc.map { CGFloat($0) })
                )
            case .outlay:
                let out = detailContainer.expenditureByUnit.totalAmounts
                chartDataArray.append(
                    BarChartData(groupName: "Outlay", values: out.map { CGFloat($0) })
                )
            }
        }
        
        return .init(
            dataLabels: detailContainer.dateLabels,
            dataSource: chartDataArray
        )
    }
    
    fileprivate static func unitPeriod(period: DateOffsetter.PeriodUnit) -> TransactionsDetail.UnitPeriod {
        switch period {
        case .day:
            return .day
        case .week:
            return .day
        case .month:
            return .day
        case .year:
            return .month
        }
    }
}

