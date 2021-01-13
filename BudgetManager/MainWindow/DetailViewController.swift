//
//  MainSplitViewController.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/03.
//

import Cocoa

public class DetaiViewController: NSViewController {
    private var horizontalConstraints: [NSLayoutConstraint] = []
    private var verticalConstraints: [NSLayoutConstraint] = []

    @IBOutlet weak var contentBaseView: NSView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSelectionChange(_:)),
            name: SidebarViewController.selectionDidChangeNotification,
            object: nil)
    }
    
    @objc
    private func handleSelectionChange(_ notification: Notification) {
        if let vcForDetail = DetailPageViewControllerContainer.instance.detailViewControllerForSelection() {
            self.embedChildViewController(vcForDetail)
        }
    }
    private func embedChildViewController(_ childViewController: NSViewController) {
        self.addChild(childViewController)
        childViewController.view.frame = self.contentBaseView.bounds
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.contentBaseView.addSubview(childViewController.view)
        
        childViewController.view.leadingAnchor.constraint(
            equalTo: self.contentBaseView.leadingAnchor
        ).isActive = true
        childViewController.view.trailingAnchor.constraint(
            equalTo: self.contentBaseView.trailingAnchor
        ).isActive = true
        childViewController.view.topAnchor.constraint(
            equalTo: self.contentBaseView.topAnchor
        ).isActive = true
        childViewController.view.bottomAnchor.constraint(
            equalTo: self.contentBaseView.bottomAnchor
        ).isActive = true
    }
}
