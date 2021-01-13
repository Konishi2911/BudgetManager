//
//  TaxConfiguratorViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/05.
//

import Cocoa

public class TaxConfiguratorViewContorller: NSViewController {
    @IBOutlet weak var enableSwitch: NSSwitch!
    @IBOutlet weak var eightPercentButton: NSButton!
    @IBOutlet weak var tenPercentButton: NSButton!
    @IBOutlet weak var customRateButton: NSButton!
    @IBOutlet weak var customRateField: NSTextField!
    
    @IBOutlet weak var customRateFieldWidthConstraint: NSLayoutConstraint!
    
    private var actualCustomRateFieldWidth: CGFloat = 0
    public var taxRate = 0.0 {
        didSet {
            self.delegate?.taxRateDidUpdate(taxRate: self.taxRate)
        }
    }
    
    @IBOutlet weak var delegate: TaxConfiguratorDelegate?
    
    public override func viewDidLoad() {
        actualCustomRateFieldWidth = self.customRateField.bounds.width
        
        toggleStateOfTaxButtons(enable: false)
        toggleSubCategoryField(disclose: false)
        
        if self.taxRate != 0.0 {
            self.toggleStateOfTaxButtons(enable: true)
            switch taxRate {
            case 0.08: self.eightPercentButton.state = .on
            case 0.1: self.tenPercentButton.state = .on
            default:
                self.customRateButton.state = .on
                self.toggleSubCategoryField(disclose: true)
                self.customRateField.doubleValue = self.taxRate
            }
        }
    }
    
    @IBAction func enableSwitchStateDidChange(_ sender: NSSwitch) {
        toggleStateOfTaxButtons(
            enable: self.enableSwitch.state == .on
        )
        if self.enableSwitch.state == .off {
            self.taxRate = 0.0
        }
    }
    @IBAction func taxRateDidChange(_ sender: NSButton) {
        if self.customRateButton.state == .on {
            self.toggleSubCategoryField(disclose: true)
        } else {
            self.toggleSubCategoryField(disclose: false)
            if eightPercentButton.state == .on {
                self.taxRate = 0.08
            } else if self.tenPercentButton.state == .on {
                self.taxRate = 0.1
            }
        }
    }
    
    private func toggleStateOfTaxButtons(enable: Bool) {
        self.eightPercentButton.isEnabled = enable
        self.tenPercentButton.isEnabled = enable
        self.customRateButton.isEnabled = enable
        self.customRateField.isEnabled = enable
    }
    private func toggleSubCategoryField(disclose: Bool) {
        let height = disclose ? self.actualCustomRateFieldWidth : 0.0
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.customRateFieldWidthConstraint.animator().constant = height
        })
    }
}
