//
//  BarChartDataSourceCollection.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/11/23.
//

import Cocoa

public struct BarChartData {
    let groupName: String
    let values: [CGFloat]
}

public struct BarChartDataSource {
    private(set) var groupNames: [String] = []
    private(set) var dataLabels: [String] = []
    private(set) var dataTable: [[CGFloat]] = []
    
    var max: Double {
        precondition(!self.dataTable.isEmpty)
        return Double(self.dataTable.max { $0.max()! < $1.max()! }!.max()!)
    }
    
    /// the number of data clusters in the collection.
    let numberOfDataClusters: Int
    let groupSize: Int
    
    /// <#Description#>
    /// - Parameters:
    ///   - groupSize: The number of values in a group.
    ///   - dataSource: <#dataSource description#>
    init(groupSize: Int, dataLabels: [String], dataSource: (Int) -> BarChartData) {
        self.groupSize = groupSize
        self.dataLabels = dataLabels
        self.numberOfDataClusters = dataLabels.count
        for i in 0 ..< groupSize {
            self.groupNames.append(dataSource(i).groupName)
            self.dataTable.append(dataSource(i).values)
        }
    }
    init(dataLabels: [String], dataSource: [BarChartData]) {
        self.groupSize = dataSource.count
        self.dataLabels = dataLabels
        self.numberOfDataClusters = dataLabels.count
        for i in 0 ..< groupSize {
            self.groupNames.append(dataSource[i].groupName)
            self.dataTable.append(dataSource[i].values)
        }
    }
    
    func values(groupNoOf no: Int) -> [CGFloat] {
        precondition(self.groupSize > no)
        return self.dataTable[no]
    }
    func values(labelNoOf no: Int) -> [CGFloat] {
        precondition(self.numberOfDataClusters > no)
        return self.dataTable.map { $0[no] }
    }
}
