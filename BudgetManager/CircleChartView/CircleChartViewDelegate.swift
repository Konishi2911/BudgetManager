//
//  CircleChartDataSource.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/11/23.
//

import Cocoa

public protocol CircleChartViewDelegate {
    func numberOfElement() -> Int
    func dataSource(elementNumber: Int) -> CircleChartData
}

public struct CircleChartData {
    let title: String
    let value: CGFloat
}
