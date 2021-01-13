//
//  TaxConfiguratorDelegate.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/05.
//

import Cocoa

@objc public protocol TaxConfiguratorDelegate {
    @objc func taxRateDidUpdate(taxRate: Double)
}
