//
//  UsageOverviewViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/15.
//

import Cocoa
import BudgetCoreDatabase

public class UsageOverviewViewController: NSViewController {
    @IBOutlet weak var outlayAmountField: NSTextField!
    @IBOutlet weak var incomeAmountField: NSTextField!
    
    @IBOutlet weak var outlayTrendIndicator: NSImageView!
    @IBOutlet weak var incomeTrendIndicator: NSImageView!
    
    var refDate: Date = .init() {
        didSet {
            targetPeriod = TargetDateIntervalProvider(
                period: self.periodUnit,
                refDate: self.refDate
            ).targetPeriod
            
            previousPeriod = TargetDateIntervalProvider(
                period: self.periodUnit,
                refDate: DateOffsetter(dateComponent: self.periodUnit)
                    .offset(from: self.refDate, value: -1)!
            ).targetPeriod
            
            self.reloadData()
        }
    }
    var periodUnit: DateOffsetter.PeriodUnit = .year {
        didSet {
            targetPeriod = TargetDateIntervalProvider(
                period: self.periodUnit,
                refDate: self.refDate
            ).targetPeriod
            
            previousPeriod = TargetDateIntervalProvider(
                period: self.periodUnit,
                refDate: DateOffsetter(dateComponent: self.periodUnit)
                    .offset(from: self.refDate, value: -1)!
            ).targetPeriod
            
            self.reloadData()
        }
    }
    
    private var datasource: TransactionsDetail?
    private var targetPeriod: DateInterval = TargetDateIntervalProvider(
        period: .year,
        refDate: Date()
    ).targetPeriod
    private var previousPeriod: DateInterval = TargetDateIntervalProvider(
        period: .year,
        refDate: DateOffsetter(dateComponent: .year)
            .offset(from: Date(), value: -1)!
    ).targetPeriod
    
    public override func viewDidLoad() {
        self.reloadData()
    }
    
    public override func viewDidLayout() {
        self.updateDisplay()
    }
    
    public func reloadData() {
        self.updateData()
        self.updateDisplay()
    }
    
    private func updateData() {
        datasource = .init(
            TransactionDataBase.default.table,
            for: self.targetPeriod,
            by: .day
        )
        
        let comparator = UsageComparator(
            currentUsage: self.datasource!,
            previousUsage: .init(
                TransactionDataBase.default.table,
                for: self.previousPeriod,
                by: .day
            )
        )
        self.setIndicator(value: comparator.totalIncome,
                          indicator: self.incomeTrendIndicator)
        self.setIndicator(value: comparator.totalOutlay,
                          indicator: self.outlayTrendIndicator)
        
    }
    private func updateDisplay() {
        outlayAmountField.integerValue = datasource?.expenditure.totalAmounts ?? 0
        incomeAmountField.integerValue = datasource?.income.totalAmounts ?? 0
    }
    
    private func setIndicator(value: Int, indicator: NSImageView) {
        if value > 0 {
            indicator.image = NSImage(systemSymbolName: "arrow.up.circle.fill",
                                      accessibilityDescription: nil)
            indicator.symbolConfiguration = .init(scale: .large)
            indicator.contentTintColor = NSColor.systemRed
        } else if value == 0 {
            indicator.image = NSImage(systemSymbolName: "minus.circle.fill",
                                      accessibilityDescription: nil)
            indicator.symbolConfiguration = .init(scale: .large)
            indicator.contentTintColor = NSColor.systemGreen
        } else {
            indicator.image = NSImage(systemSymbolName: "arrow.down.circle.fill",
                                      accessibilityDescription: nil)
            indicator.symbolConfiguration = .init(scale: .large)
            indicator.contentTintColor = NSColor.systemBlue
        }
    }
}

public struct UsageComparator {
    let currentUsage: TransactionsDetail
    let previousUsage: TransactionsDetail
    
    var totalOutlay: Int {
        currentUsage.expenditure.totalAmounts - previousUsage.expenditure.totalAmounts
    }
    var totalIncome: Int {
        currentUsage.income.totalAmounts - previousUsage.income.totalAmounts
    }
    var totalOutlayPercentage: Double {
        Double(currentUsage.expenditure.totalAmounts) / Double(previousUsage.expenditure.totalAmounts)
    }
    var totalIncomePercentage: Double {
        Double(currentUsage.income.totalAmounts) / Double(previousUsage.income.totalAmounts)
    }
}
