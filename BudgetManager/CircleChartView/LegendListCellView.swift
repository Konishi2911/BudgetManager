//
//  LegendListCellView.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/03.
//

import Cocoa

public class LegendListCellView: NSTableCellView {
    @IBOutlet weak var _baseView: NSView! {
        didSet {
            self.frame = _baseView.bounds
            self.addSubview(_baseView)
        }
    }
    
    @IBOutlet weak var symbol: NSBox!
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var values: NSTextField!
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadNib()
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    
    private func loadNib() {
        if let _nib = NSNib(nibNamed: "LegendListCellView", bundle: nil) {
            _nib.instantiate(withOwner: self, topLevelObjects: nil)
        }
    }
}
