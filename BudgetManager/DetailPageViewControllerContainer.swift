//
//  DetailPageViewControllerContainer.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/03.
//

import Cocoa

public struct DetailPageViewControllerContainer {
    public static var instance: DetailPageViewControllerContainer = .init()
    
    public var selectedPageIndex: Int = 0
    private var homeViewController: HomeViewController!
    
    init() {
        let storyboard = NSStoryboard(name: "Contents", bundle: nil)
        
        homeViewController = storyboard.instantiateController(withIdentifier: "HomeViewController") as? HomeViewController
    }
    
    public func detailViewControllerForSelection() -> NSViewController? {
        switch self.selectedPageIndex {
        case 0:
            return self.homeViewController
        default:
            return nil
        }
    }
}
