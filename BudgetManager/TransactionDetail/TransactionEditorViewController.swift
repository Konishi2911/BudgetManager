//
//  TransactionDetailViewViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/04.
//

import Cocoa
import MapKit
import BudgetCoreDatabase

public class TransactionEditorViewController: NSViewController,
                                              TaxConfiguratorDelegate {
    
    @IBOutlet weak var titleView: NSTextField!
    @IBOutlet weak var transactionTypeSelector: NSSegmentedControl!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var categoryPopup: NSPopUpButton!
    @IBOutlet weak var subCategoryPopup: NSPopUpButton!
    @IBOutlet weak var amountsField: NSTextField!
    @IBOutlet weak var taxIndicator: NSTextField!
    @IBOutlet weak var quantityField: NSTextField!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var remarksField: NSTextField!
    @IBOutlet weak var shopNameField: NSTextField!
    @IBOutlet weak var shopLocationField: NSTextField!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var subCategoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalFieldsHeightConstraint: NSLayoutConstraint!
    
    public var delegate: TransactionEditorDelegate?
    
    private var actualSubCategoryFieldHeight: CGFloat = 16
    private var actualAdditionalFieldsHeight: CGFloat = 240
    
    private var taxRate: Double = 0.0
    internal var transaction: Transaction? {
        didSet {
            if let record = self.transaction {
                self.initializeFields(with: record)
            } else {
                self.initializeFields()
            }
        }
    }
    private func initializeFields() {
        self.titleView.stringValue = "New Usage"
        self.transactionTypeSelector.selectedSegment = 0
        self.setCategoryItem(transactionType: .income)
    }
    private func initializeFields(with record: Transaction) {
        self.titleView.stringValue = "Edit Usage"
        
        // Set TransactionType from categoryType
        let selectedCategory = record.category
        let transactionType = selectedCategory.transactionType
        if  transactionType == .income {
            transactionTypeSelector.selectedSegment = 0

        } else if transactionType == .expenditure {
            transactionTypeSelector.selectedSegment = 1
            
        }
        
        // Category
        setCategoryItem(transactionType: transactionType, name: selectedCategory.categoryNameSequence)
                
        datePicker.dateValue = record.date
        amountsField.integerValue = Int(record.amounts)
        quantityField.integerValue = Int(record.pieces)
        nameField.stringValue = record.name
        remarksField.stringValue = String(record.remarks)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        transactionTypeSelector.selectedSegment = 0
        self.setCategoryItem(transactionType: .income)
        self.additionalFieldsHeightConstraint.constant = 0
    }
    
    // MARK: - Toggle Aditional Fields
    
    @IBAction func toggleAdditionalFields(_ sender: NSButton) {
        self.toggleAdditionalFields(disclose: sender.state == .on)
    }
    
    // MARK: -Tax Configuration
    
    @IBAction func taxPresetStatusDidChange(_ sender: NSButton) {
        if sender.state == .on {
            self.taxRate = 0.08
            self.taxIndicator.doubleValue = taxRate
        } else if sender.state == .off {
            self.taxRate = 0
            self.taxIndicator.stringValue = "No Tax"
        }
    }
    public func taxRateDidUpdate(taxRate: Double) {
        self.taxRate = taxRate
        if taxRate == 0 {
            self.taxIndicator.stringValue = "No Tax"
        } else {
            self.taxIndicator.doubleValue = taxRate
        }
    }
    
    public override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        // Tax Configurator View Controller
        if let taxConfigVC = segue.destinationController as?
            TaxConfiguratorViewContorller {
            taxConfigVC.delegate = self
            taxConfigVC.taxRate = self.taxRate
        }
    }
    
    // MARK: - Transaction Type or Transaction Category Selection Did Change
    
    @IBAction func transactionTypeDidChange(_ sender: NSSegmentedControl) {
        let transactionType: TransactionType
        switch self.transactionTypeSelector.selectedSegment {
        case 0:
            transactionType = .income
        case 1:
            transactionType = .expenditure
        default:
            return
        }
        self.setCategoryItem(transactionType: transactionType)
    }
    @IBAction func categoryDidChange(_ sender: Any) {
        let transactionType: TransactionType
        switch self.transactionTypeSelector.selectedSegment {
        case 0:
            transactionType = .income
        case 1:
            transactionType = .expenditure
        default:
            return
        }
        if let item = self.categoryPopup.selectedItem {
            setCategoryItem(transactionType: transactionType, name: [item.title])
        }
    }
    
    // MARK: - Accepting and Canceling New Item or Editing
        
    @IBAction func cancelButtonDidClick(_ sender: NSButton) {
         self.view.window?.close()
     }
    
    @IBAction func acceptButtonDidClick(_ sender: NSButton) {
        guard let categoryValue = TransactionCategoryValue(
                type: selectedTransactionType,
                categoryNames: currentCategoryValue) else {
            return
        }
        
        let taxRate = self.taxRate
        let amounts = Int(floor(Double(amountsField.intValue) * (1 + taxRate)))
        let transaction = Transaction(
            date: datePicker.dateValue,
            category: categoryValue,
            name: nameField.stringValue,
            pieces: Int(quantityField.intValue),
            amounts: amounts,
            remarks: remarksField.stringValue
        )
        
        self.delegate?.recordDidChange(
            currentRecord: self.transaction,
            newRecord: transaction
        )
        
        self.view.window?.close()
    }
    
    
    // MARK: - Private Helpers
    
    // MARK: Convenience Properties
    private var selectedTransactionType: TransactionType {
         switch transactionTypeSelector.selectedSegment {
         case 0:
             return .income
         case 1:
             return .expenditure
         default:
             return .income
         }
     }
    
    private var currentCategoryValue: [String] {
         var categoryNameArray: [String] = []
         if let categoryName = categoryPopup.selectedItem?.title {
             categoryNameArray.append(categoryName)
             if let subCategoryName = subCategoryPopup.selectedItem?.title {
                 categoryNameArray.append(subCategoryName)
             }
         }
         return categoryNameArray
     }
    
    // MARK: Methods
    
    private func setCategoryItem(transactionType: TransactionType, name: [String]? = nil) {
            let categoryNameSequence: [String]
            if let _name = name {
                categoryNameSequence = transactionType.categoryItemsProvider.getNameSequence(
                    categoryNamesArray: _name,
                    policy: .defaultWhenMissing
                )
            } else {
                categoryNameSequence = transactionType.categoryItemsProvider.defaultNameSequence
            }
            
            categoryPopup.removeAllItems()
            let rootCategoryProvider = transactionType.categoryItemsProvider
            let rootCategoryName = categoryNameSequence.first!
            categoryPopup.addItems(withTitles: rootCategoryProvider.categoryNames)
            categoryPopup.selectItem(withTitle: rootCategoryName)
            
            subCategoryPopup.removeAllItems()
            if let subCategoryProvder = rootCategoryProvider.subCategory(rootCategoryName),
               !(subCategoryProvder.isEmpty) {
                let subCategoryName = categoryNameSequence[1]
                subCategoryPopup.addItems(withTitles: subCategoryProvder.categoryNames)
                subCategoryPopup.selectItem(withTitle: subCategoryName)
                toggleSubCategoryField(disclose: true)
            } else {
                toggleSubCategoryField(disclose: false)
            }
        }
    
    private func toggleSubCategoryField(disclose: Bool) {
        let height = disclose ? self.actualSubCategoryFieldHeight : 0.0
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.subCategoryHeightConstraint.animator().constant = height
        })
    }
    
    private func toggleAdditionalFields(disclose: Bool) {
        let height = disclose ? self.actualAdditionalFieldsHeight : 0.0
        
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.additionalFieldsHeightConstraint.animator().constant = height
        }, completionHandler: {
            print("done resizing with \(self.additionalFieldsHeightConstraint.constant)")
        })
    }
}
