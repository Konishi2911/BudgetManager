//
//  BarChartViewDelegate.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/11/19.
//

import Cocoa

// MARK: - Plot Item

@objc public class PlotItem: NSObject {
    let title: String
    let value: [CGFloat]
    
    init(title: String, value: [CGFloat]) {
        self.title = title
        self.value = value
    }
}

// MARK: - Delegate

@objc public protocol BarChartViewDelegate {
    var numberOfElements: UInt { get }
    var numberOfValuesInAGroup: UInt { get }
    func dataSource(clusterIndexOf index: UInt) -> PlotItem
}
