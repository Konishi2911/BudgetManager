//
//  TargetPeriodManager.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/09.
//

import Cocoa

// MARK: - Target Date Interval Provider

internal struct TargetDateIntervalProvider {
    internal typealias PeriodUnit = DateOffsetter.PeriodUnit
    
    private let calendar = Calendar.current
    private(set) var targetPeriod: DateInterval = DateInterval()
    
    init(period: PeriodUnit, refDate: Date) {
        let dateComponents = calendar.dateComponents(
            DateOffsetter.calendarComponets(period: period), from: refDate
        )
        let offsetter = DateOffsetter(dateComponent: period)
        
        let startDate = calendar.date(from: dateComponents)!
        let endDate = offsetter.offset(from: startDate, value: 1)!
        
        self.targetPeriod = .init(start: startDate, end: endDate)
    }
}

// MARK: - Date Offsetter

internal struct DateOffsetter {
    enum PeriodUnit {
        case day
        case week
        case month
        case year
    }
    
    var calendar = Calendar.current
    
    private let offsetDateComponent: Calendar.Component
    
    init(dateComponent: PeriodUnit) {
        self.offsetDateComponent = Self.dateComponent(period: dateComponent)
    }
    
    func offset(from date: Date, value: Int) -> Date? {
        self.calendar.date(
            byAdding: self.offsetDateComponent,
            value: value,
            to: date
        )
    }
    
    fileprivate static func dateComponent(period: PeriodUnit) -> Calendar.Component {
        switch period {
        case .day:
            return .day
        case .week:
            return .weekOfMonth
        case .month:
            return .month
        case .year:
            return .year
        }
    }
    
    fileprivate static func calendarComponets(period: DateOffsetter.PeriodUnit) -> Set<Calendar.Component> {
        switch period {
        case .day:
            return [.year, .month, .day]
        case .week:
            return [.year, .month, .yearForWeekOfYear, .weekOfYear]
        case .month:
            return [.year, .month]
        case .year:
            return [.year]
        }
    }
}
