//
//  HomeViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/03.
//

import Cocoa
import BudgetCoreDatabase

public class HomeViewController: NSViewController, TransactionEditorDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var periodSelector: NSSegmentedControl!
    @IBOutlet weak var breakdownChartsArea: NSView!
    @IBOutlet weak var overviewArea: NSView!
    
    private var yearlyTitleFormatter: DateFormatter = .init()
    private var monthlyTitleFormatter: DateFormatter = .init()
    private var weeklyTitleFormatter: DateFormatter = .init()
    
    weak var breakdownChartsViewController: UsageBreakdownViewController!
    weak var overviewViewController: UsageOverviewViewController!
        
    var barChartDataSourceManager: UsageTrendChartDataSourceManager = .init()
        
    // MARK: Usage Table View
    
    // MARK: - Initialize Views
    public override func viewDidLoad() {
        self.view.wantsLayer = true
        
        self.periodSelector.selectedSegment = 2
        TransactionDataBase.default.table.storeTiming = .recordDicChange
        TransactionDataBase.default.table.sortTiming = .whenSortIsRequired
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        
        self.initializeFormatters()
        
        let date = self.barChartDataSourceManager.refDate
        barChartView.titleString = self.yearlyTitleFormatter.string(from: date)
        barChartView.numberFormatter = currencyFormatter
        barChartView.dataSource = self.barChartDataSourceManager.dataSource()
        
        // Embed subviews
        self.breakdownChartsViewController = self.addSubViewFromViewController(
            identifier: "UsageBreakdownVC",
            embedTo: self.breakdownChartsArea
        ) as? UsageBreakdownViewController
        
        self.overviewViewController = self.addSubViewFromViewController(
            identifier: "UsageOverviewVC",
            embedTo: self.overviewArea
        ) as? UsageOverviewViewController
        
        // Regist Notification observers
        NotificationCenter.default.addObserver(
            forName: TransactionDataBase.tableDidUpdate,
            object: nil,
            queue: .main,
            using: { n in
                self.dataSourceDidChange(n)
            }
        )
    }
    private func initializeFormatters() {
        yearlyTitleFormatter.locale = .current
        yearlyTitleFormatter.timeZone = .current
        yearlyTitleFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        
        monthlyTitleFormatter.locale = .current
        monthlyTitleFormatter.timeZone = .current
        monthlyTitleFormatter.setLocalizedDateFormatFromTemplate("MMMMYYYY")
        
        weeklyTitleFormatter.locale = .current
        weeklyTitleFormatter.timeZone = .current
        weeklyTitleFormatter.setLocalizedDateFormatFromTemplate("MMMMYYYY")
    }
    private func addSubViewFromViewController(identifier: String, embedTo view: NSView) -> NSViewController? {
        if let vc = self.storyboard?.instantiateController(withIdentifier: identifier) as? NSViewController {
            
            self.addChild(vc)
            vc.view.frame = view.bounds
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(vc.view)
            
            vc.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ).isActive = true
            vc.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ).isActive = true
            vc.view.topAnchor.constraint(
                equalTo: view.topAnchor
            ).isActive = true
            vc.view.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ).isActive = true
                        
            return vc
        }
        return nil
    }
    
    @IBAction func targetPeriodDidChange(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.barChartDataSourceManager.targetPeriodUnit = .week
            self.barChartDataSourceManager.dataComponents = [.outlay]
            
            let date = self.barChartDataSourceManager.refDate
            self.barChartView.titleString = self.weeklyTitleFormatter.string(from: date)
            
            self.breakdownChartsViewController.periodUnit = .day
            
            self.overviewViewController.periodUnit = .week
            self.overviewViewController.refDate = date
            
        } else if sender.selectedSegment == 1 {
            self.barChartDataSourceManager.targetPeriodUnit = .month
            self.barChartDataSourceManager.dataComponents = [.outlay]
            
            let date = self.barChartDataSourceManager.refDate
            self.barChartView.titleString = self.monthlyTitleFormatter.string(from: date)
            
            self.breakdownChartsViewController.periodUnit = .day
            
            self.overviewViewController.periodUnit = .month
            self.overviewViewController.refDate = date
            
        } else if sender.selectedSegment == 2 {
            self.barChartDataSourceManager.targetPeriodUnit = .year
            self.barChartDataSourceManager.dataComponents = [.income, .outlay]
            
            let date = self.barChartDataSourceManager.refDate
            self.barChartView.titleString = self.yearlyTitleFormatter.string(from: date)
            
            self.breakdownChartsViewController.periodUnit = .month
            
            self.overviewViewController.periodUnit = .year
            self.overviewViewController.refDate = date
            
        }
        
        barChartView.dataSource = self.barChartDataSourceManager.dataSource()
        self.view.needsLayout = true
    }
    
    @IBAction func goBackDidRequest(_ sender: NSButton) {
        self.barChartDataSourceManager.offsetDate(-1)
        barChartView.dataSource = self.barChartDataSourceManager.dataSource()
        
        overviewViewController.refDate = self.barChartDataSourceManager.refDate
        self.view.needsLayout = true
    }
    @IBAction func goTodayDidRequest(_ sender: Any) {
        self.barChartDataSourceManager.setToToday()
        barChartView.dataSource = self.barChartDataSourceManager.dataSource()
        
        overviewViewController.refDate = Date()
        self.view.needsLayout = true
    }
    @IBAction func goForwardDidRequest(_ sender: NSButton) {
        self.barChartDataSourceManager.offsetDate(1)
        barChartView.dataSource = self.barChartDataSourceManager.dataSource()
        
        overviewViewController.refDate = self.barChartDataSourceManager.refDate
        self.view.needsLayout = true
    }
    
    public override func viewDidLayout() {
    }
    
    private func dataSourceDidChange(_ notification: Notification) {
        barChartView.dataSource = self.barChartDataSourceManager.dataSource()
        overviewViewController.reloadData()
        self.view.needsLayout = true
    }
    
    // MARK: - Showing Detail Editor Window
    
    @IBAction func addButtonDidClick(_ sender: NSButton) {
        self.showDetailWindow()
    }
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let nextWC = segue.destinationController as?
                NSWindowController else { return }
        
        // Trasnaction Editor View
        if let nextVC = nextWC.contentViewController as?
            TransactionEditorViewController {
            nextVC.transaction = nil
            nextVC.delegate = self
        }
    }
    
    private func showDetailWindow() {
        performSegue(withIdentifier: "showDetailDialog", sender: self)
    }
    
    // MARK: -Receiving Edited Record
    public func recordDidChange(currentRecord: Transaction?, newRecord: Transaction) {
        let dbHelper = TransactionDBHelper()
        if let record = currentRecord {
            dbHelper.replaceRequest(record, to: newRecord)
        } else {
            dbHelper.addRequest(newRecord)
        }
    }
}
