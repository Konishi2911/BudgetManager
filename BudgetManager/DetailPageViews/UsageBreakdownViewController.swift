//
//  UsageBreakdownViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/08.
//

import Cocoa
import BudgetCoreDatabase

internal protocol UsageBreakdownDelegate {
    var breakdownChartsTargetPeriodUnit: DateOffsetter.PeriodUnit { get }
}

public class UsageBreakdownViewController: NSViewController {
    @IBOutlet weak var outlayBreakdownChart: CircleChartView!
    @IBOutlet weak var incomeBreakdownChart: CircleChartView!
    @IBOutlet weak var targetPeriodIndicator: NSTextField!
    
    var periodUnit: DateOffsetter.PeriodUnit = .month {
        didSet {
            self.view.needsLayout = true
        }
    }
    private var dataSourceManager: UsageBreakdownChartDataSourceManager = .init()
    
    public override func viewDidLoad() {
        self.outlayBreakdownChart.titleString = "Outlay"
        self.incomeBreakdownChart.titleString = "Income"
        
        self.outlayBreakdownChart.dataSource = self.dataSourceManager.dataSource(.outlay)
        self.incomeBreakdownChart.dataSource = self.dataSourceManager.dataSource(.income)
        
        self.targetPeriodIndicator.objectValue = self.dataSourceManager.targetPeriod
        
        NotificationCenter.default.addObserver(
            forName: TransactionDataBase.tableDidUpdate,
            object: nil,
            queue: .main,
            using: { self.dataSourceDidChange($0) }
        )
    }
    
    public override func viewDidLayout() {
        self.updateData()
    }
    
    @IBAction func goBackDidRequest(_ sender: NSButton) {
        self.dataSourceManager.offsetDate(-1)
        updateData()
    }
    @IBAction func goForwardDidRequest(_ sender: NSButton) {
        self.dataSourceManager.offsetDate(1)
        updateData()
    }
    
    
    private func updateData() {
        self.dataSourceManager.targetPeriodUnit = self.periodUnit
        
        self.outlayBreakdownChart.dataSource = self.dataSourceManager.dataSource(.outlay)
        self.incomeBreakdownChart.dataSource = self.dataSourceManager.dataSource(.income)
        
        self.targetPeriodIndicator.objectValue = self.dataSourceManager.targetPeriod
    }
    
    private func dataSourceDidChange(_ notification: Notification) {
        self.incomeBreakdownChart.dataSource = self.dataSourceManager.dataSource(.income)
        self.outlayBreakdownChart.dataSource = self.dataSourceManager.dataSource(.outlay)
    }
}
