//
//  DataContainerForChart.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/09.
//

import Foundation
import BudgetCoreDatabase

// MARK: - Data Comtainer For Bar Chart

internal struct DataContainerForChart {
    
    private let calendar = Calendar.current
    private var targetPeriod: DateInterval = DateInterval()

    init (period: DateInterval) {
        self.targetPeriod = period
    }
    
    func getDetailDataContainer(unitPeriod: TransactionsDetail.UnitPeriod) -> TransactionsDetail {
        return TransactionsDetail(
            TransactionDataBase.default.table,
            startFrom: self.targetPeriod.start, to: self.targetPeriod.end,
            by: unitPeriod
        )
    }
}
