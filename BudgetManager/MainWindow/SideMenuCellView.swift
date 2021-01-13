//
//  SideMenuCellView.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/03.
//

import Cocoa

public class SideMenuCellView: NSTableCellView {
    @IBOutlet weak var _baseView: NSTableCellView! {
        didSet {
            self.frame = _baseView.bounds
            self.addSubview(_baseView)
        }
    }
    
    @IBOutlet weak var menuTitle: NSTextField!
    @IBOutlet weak var icon: NSImageView!
    
    // MARK: - Initialization
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadNib()
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    private func loadNib() {
        if let _nib = NSNib(nibNamed: "SideMenuCellView", bundle: nil) {
            _nib.instantiate(withOwner: self, topLevelObjects: nil)
        }
    }
}
