//
//  SidebarViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/03.
//

import Cocoa

public class SidebarViewController: NSViewController,
                                    NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var tableView: NSTableView!
    
    static let selectionDidChangeNotification =  Notification.Name(
        "selectionDidChangeNotification"
    )
    private static let sideMenuItems: KeyValuePairs<NSImage, String> = [
        NSImage(systemSymbolName: "house", accessibilityDescription: nil)! : "Home"
    ]
    
    // MARK: - Table View Delegates and Datasources for Side Menu
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        Self.sideMenuItems.count
    }
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(
                withIdentifier: .init(rawValue: "sideMenuCell"),
                owner: self) as? SideMenuCellView
        else { return nil }
        
        cellView.icon.image! = Self.sideMenuItems[row].key
        cellView.menuTitle.stringValue = Self.sideMenuItems[row].value
        
        return cellView
    }
    public func tableViewSelectionDidChange(_ notification: Notification) {
        DetailPageViewControllerContainer.instance.selectedPageIndex = self.tableView.selectedRow
        NotificationCenter.default.post(
            Notification(name: Self.selectionDidChangeNotification)
        )
    }
}
