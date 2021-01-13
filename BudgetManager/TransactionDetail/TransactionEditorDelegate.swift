//
//  TransactionEditorDelegate.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/05.
//

import Cocoa
import BudgetCoreDatabase

public protocol TransactionEditorDelegate {
    func recordDidChange(currentRecord: Transaction?, newRecord: Transaction)
}
