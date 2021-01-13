//
//  UsageJournalViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/04.
//

import Cocoa
import BudgetCoreDatabase

public class UsageJournalViewController: NSViewController,
                                         NSTableViewDelegate, NSTableViewDataSource,
                                         TransactionEditorDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addItemButton: NSButton!
    @IBOutlet weak var removeItemButton: NSButton!
    
    private var records: [Transaction] = []
    private var selectedTransaction: Transaction?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Records from Transaction Database.
        self.fetchRecords()
        
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(
            forName: TransactionDataBase.tableDidUpdate,
            object: nil,
            queue: .main,
            using: {
                self.transactionTableDidChange($0)
            }
        )
    }
    
    public override func viewDidLayout() {
    }
    public override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(
            self,
            name: TransactionDataBase.tableDidUpdate,
            object: nil
        )
    }

    // MARK: - Load Records to Show Table View
    
    @objc
    private func transactionTableDidChange(_ notification: Notification) {
        fetchRecords()
        self.tableView.reloadData()
    }
    
    private func fetchRecords() {
        self.records = TransactionDataBase.default.table.getAllRecords()
    }
    
    // MARK: - Adding and Removeing Usage
    
    @IBAction func addButtonDidClick(_ sender: NSButton) {
        self.selectedTransaction = nil
        self.showDetailWindow()
    }
    
    @IBAction func removeButtonDidClick(_ sender: NSButton) {
        
    }
    
    
    // MARK: - Table View Delegates and Datasources
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        self.records.count
    }
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn else { return nil }
        
        guard let cellView = tableView.makeView(
                withIdentifier: column.identifier,
                owner: self) as? NSTableCellView else { return nil }
        
        let record = self.records[row]
        
        switch column.identifier.rawValue {
        case "Date":
            cellView.textField?.objectValue = record.date
        case "Category":
            cellView.textField?.stringValue = record.category.categoryNameSequence.first!
        case "Subtotal":
            cellView.textField?.integerValue = (record.amounts * record.pieces)
        case "Remarks":
            cellView.textField?.stringValue = record.remarks
        default:
            return nil
        }
        return cellView
    }
    public func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if row != -1 {
            self.selectedTransaction = records[row]
        } else {
            self.selectedTransaction = nil
        }
    }
    
    // MARK: - Showing Detail Editor Window
    
    @IBAction func tableViewDidDoubleClick(_ sender: NSTableView) {
        guard self.selectedTransaction != nil else { return }
        self.showDetailWindow()
    }
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let nextWC = segue.destinationController as?
                NSWindowController else { return }
        
        // Trasnaction Editor View
        if let nextVC = nextWC.contentViewController as?
            TransactionEditorViewController {
            nextVC.transaction = self.selectedTransaction
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
