//
//  CircleChartDataSourceManager.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/09.
//

import Cocoa
import BudgetCoreDatabase

public struct UsageBreakdownChartDataSourceManager {
    enum Component {
        case outlay
        case income
    }
    
    var component: Component = .outlay
    var targetPeriodUnit: DateOffsetter.PeriodUnit = .month {
        didSet { self.updateTargetPeriod() }
    }
    var refDate: Date = Date() {
        didSet { self.updateTargetPeriod() }
    }
    
    private(set) var targetPeriod: DateInterval = DateInterval()
    private mutating func updateTargetPeriod() {
        self.targetPeriod = TargetDateIntervalProvider(
            period: self.targetPeriodUnit, refDate: self.refDate
        ).targetPeriod
    }
    
    init() {
        self.updateTargetPeriod()
    }
    
    mutating func offsetDate(_ offset: Int) {
        let offsetter = DateOffsetter(dateComponent: self.targetPeriodUnit)
        self.refDate = offsetter.offset(from: self.refDate, value: offset)!
    }
    mutating func setToToday() {
        self.refDate = Date()
    }
    
    func dataSource(_ component: Component) -> CircleChartDataSource {
        let detailDataContainer = DataContainerForChart(period: self.targetPeriod)
        
        let detailContainer = detailDataContainer.getDetailDataContainer(
            unitPeriod: Self.unitPeriod(period: self.targetPeriodUnit)
        )
        
        let breakdown: BreakdownStorage
        switch component {
        case .income:
            breakdown = detailContainer.income.breakdown
        case .outlay:
            breakdown = detailContainer.expenditure.breakdown
        }
        
        var chartDataArray: [CircleChartData] = []
        for item in breakdown {
            chartDataArray.append(.init(title: item.0, value: CGFloat(item.1)))
        }
        
        return .init(dataSource: chartDataArray)
    }
    
    fileprivate static func unitPeriod(period: DateOffsetter.PeriodUnit) -> TransactionsDetail.UnitPeriod {
        switch period {
        case .day:
            return .day
        case .week:
            return .week
        case .month:
            return .month
        case .year:
            return .year
        }
    }
}
