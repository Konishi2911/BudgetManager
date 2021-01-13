//
//  TransactionDBHelper.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/06.
//

import Cocoa
import BudgetCoreDatabase

public struct TransactionDBHelper {
    let databaseTaskQueue = DispatchQueue.global(qos: .userInitiated)
    
    func addRequest(_ newRecord: Transaction) {
        databaseTaskQueue.async {
            TransactionDataBase.default.table.add(newRecord)
        }
    }
    func removeRequest(_ target: Transaction) {
        databaseTaskQueue.async {
            TransactionDataBase.default.table.remove(target)
        }
    }
    func replaceRequest(_ oldRecord: Transaction, to newRecord: Transaction) {
        databaseTaskQueue.async {
            TransactionDataBase.default.table.replace(oldRecord, to: newRecord)
        }
    }
}
