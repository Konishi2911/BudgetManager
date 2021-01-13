//
//  CircleChartView.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/11/23.
//

import Cocoa

@IBDesignable
public class CircleChartView: NSView, NSTableViewDataSource, NSTableViewDelegate {
    /// The veiw loaded from nib
    @IBOutlet var _baseView: NSView! {
        didSet {
            _baseView.frame = self.bounds
            self.addSubview(self._baseView)
        }
    }
    @IBOutlet weak var chartView: NSView!
    @IBOutlet weak var titleView: NSTextField!
    @IBOutlet weak var legendListView: NSTableView!
    
        
    // MARK: - Properties
    
    var dataSource: CircleChartDataSource = .empty {
        didSet {
            self.needsDisplay = true
        }
    }
    
    // MARK: Title
    var titleString: String = "Title"
    
    // MARK: Legend
    private var legendFont: NSFont = NSFont.systemFont(ofSize: 14, weight: .semibold)
    var legendFontColor: NSColor = NSColor.textColor
    var legendValueColor: NSColor = NSColor(named: "CircleChartView_RawValueColor")!
    var percentageFormat: NumberFormatter?
    private var _percentageFormat: NumberFormatter {
        if let _pformatter = self.percentageFormat { return _pformatter }
        else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            return formatter
        }
    }
    var rawValueFormat: NumberFormatter = NumberFormatter()
    
    // MARK: Charts
    /// Colors Collection for chart circle.
    var chartColorSet: [NSColor] = [
        #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1),#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),#colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1),#colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1),#colorLiteral(red: 0.04369917915, green: 0.2984071599, blue: 0.1203140421, alpha: 1)
    ]
        
    // MARK: - Initialization
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        loadNib()
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    
    private func loadNib() {
        if let _nib = NSNib(nibNamed: "CircleChartView", bundle: nil) {
            _nib.instantiate(withOwner: self, topLevelObjects: nil)
        }
    }
    
    // MARK: For Interface Builder
    
    public override func prepareForInterfaceBuilder() {
        self.dataSource = CircleChartDataSource(
            dataSource: [
                .init(title: "Elephant", value: 100),
                .init(title: "Mammoth", value: 400)
            ]
        )
    }
    
    // MARK: - UI Methods
    
    public override var wantsUpdateLayer: Bool { return true }
    
    public override func updateLayer() {
    
        // Set Title
        self.titleView.stringValue = self.titleString
        
        // Set Legend
        self.legendListView.reloadData()
            
        // Re-Drawing Chart
        let chartLayerManager = ChartLayerManager(
            area: self.chartView.bounds,
            chartColorSet: self.chartColorSet,
            circleChartWidth: 20,
            source: self.dataSource
        )
        self._clearChart()
            
        for layer in chartLayerManager.layers() {
            self.chartView.layer?.addSublayer(layer)
        }
    }
    
    /// Clear all chart elements.
    private func _clearChart() {
        guard let subLayers = self.chartView.layer?.sublayers else { return }
        for subLayer in subLayers {
            subLayer.removeFromSuperlayer()
        }
        self.chartView.layer?.sublayers?.removeAll()
    }
    
    // MARK: - Table View DataSource and Delegates
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        self.dataSource.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(
                withIdentifier: .init(rawValue: "legendListCell"),
                owner: self) as? LegendListCellView
        else { return nil }
        
        let percentString = self._percentageFormat.string(
            from: NSNumber(value: Double(dataSource.percentage(indexOf: row)))
        )!
        let rawValueString = self.rawValueFormat.string(
            from: NSNumber(value: Double(dataSource.value(indexOf: row)))
        )!
        
        cellView.title.stringValue = self.dataSource.titles[row]
        cellView.symbol.fillColor = self._getColor(fromNumber: row)
        cellView.values.stringValue = percentString + " | " + rawValueString
        return cellView
    }
    /// Returns `CGColor` from the given number.
    private func _getColor(fromNumber number: Int) -> NSColor {
        precondition(self.chartColorSet.count != 0)
        
        let numberOfColors = self.chartColorSet.count
        return self.chartColorSet[number % numberOfColors]
    }
}

// MARK: - Chart Layer Manager

fileprivate struct ChartLayerManager {
    enum HorizontalAlignment {
        case right
        case center
        case left
    }
    
    // MARK: - Properties
    
    /// A minimum margine from border of drawing area.
    private let margine: CGFloat = 15
    private let shadowColor: CGColor = NSColor.shadowColor.cgColor
    private let blarRadius: CGFloat = 2
    private let hAlignment: HorizontalAlignment = .right
    
    let chartArea: CGRect
    
    /// Colors Collection for chart circle.
    let chartColorSet: [NSColor]

    /// Width of circle path.
    let circleChartWidth: CGFloat
    
    // MARK: Datasources
    
    /// Datasource to draw chart
    let dataSource: CircleChartDataSource
    
    // MARK: - Initializations
    
    init(area rect: CGRect, chartColorSet: [NSColor], circleChartWidth: CGFloat, source: CircleChartDataSource) {
        self.chartArea = rect
        self.chartColorSet = chartColorSet
        self.circleChartWidth = circleChartWidth
        self.dataSource = source
    }
    
    // MARK: - Layers
    
    func layers() -> [CAShapeLayer] {
        var layers: [CAShapeLayer] = []
        
        layers.append(self.shadowLayer_())
        layers.append(self.chartCircleLayers_())
        
        return layers
    }
    
    // MARK: - Chart Circle Layers
    
    private func chartCircleLayers_() -> CAShapeLayer {
        guard self.dataSource.count != 0 else { return CAShapeLayer() }
        
        let superLayer = CAShapeLayer()
        var counter = 0
        var startAngle = 0.5 * CGFloat.pi
        for percentage in dataSource.percentages {
            let path = CGMutablePath()
            let endAngle = startAngle - 2 * .pi * percentage
            path.addArc(center: self._center(),
                        radius: self._radius(),
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: true
            )
            
            let layer = CAShapeLayer()
            layer.fillColor = .none
            layer.lineWidth = self.circleChartWidth
            layer.strokeColor = self._getColor(fromNumber: counter)
            layer.path = path
            layer.lineCap = .butt
            
            superLayer.addSublayer(layer)
            startAngle = endAngle
            counter += 1
        }
        return superLayer
    }
    
    // MARK: - Shadow Layers
    
    private func shadowLayer_() -> CAShapeLayer {
        let path = CGMutablePath()
        path.addArc(center: self._center(),
                    radius: self._radius() + 0.5 * self.circleChartWidth,
                    startAngle: 0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: true
        )
        path.addArc(center: self._center(),
                    radius: self._radius() - 0.5 * self.circleChartWidth,
                    startAngle: 0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: false
        )
        
        let layer = CAShapeLayer()
        layer.frame = chartArea
        layer.shadowPath = path
        layer.shadowOpacity = 1
        layer.lineWidth = self.circleChartWidth
        layer.shadowColor = self.shadowColor
        layer.shadowRadius = self.blarRadius
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
        return layer
    }
    
    // MARK: - Private Helters
    
    private func _center() -> CGPoint {
        switch self.hAlignment {
        case .right:
            return CGPoint(x: self.chartArea.width
                            - self._radius() - self.circleChartWidth - self.margine,
                           y: self.chartArea.height * 0.5)
        case .center:
            return CGPoint(x: self.chartArea.width * 0.5,
                           y: self.chartArea.height * 0.5)
        case .left:
            return CGPoint(x: self._radius() + self.circleChartWidth + self.margine,
                           y: self.chartArea.height * 0.5)
        }
    }
    
    private func _radius() -> CGFloat {
        var length: CGFloat = 0.0
        if self.chartArea.height > self.chartArea.width {
            length = self.chartArea.width
        } else {
            length = self.chartArea.height
        }
        
        return 0.5 * length - self.circleChartWidth - margine
    }
    
    /// Returns `CGColor` from the given number.
    private func _getColor(fromNumber number: Int) -> CGColor {
        precondition(self.chartColorSet.count != 0)
        
        let numberOfColors = self.chartColorSet.count
        return self.chartColorSet[number % numberOfColors].cgColor
    }
}

// MARK: - DataSource Processor

public struct CircleChartDataSource {
    fileprivate static let empty: CircleChartDataSource = .init(dataSource: [])
    
    let dataSource: [CircleChartData]
    
    var count: Int { dataSource.count }
    var percentages: [CGFloat] {
        let total = dataSource.reduce(0) { $0 + $1.value }
        return self.dataSource.map { $0.value / total }
    }
    var values: [CGFloat] {
        return self.dataSource.map { $0.value }
    }
    var titles: [String] {
        return self.dataSource.map { $0.title }
    }
    
    func value(indexOf index: Int) -> CGFloat{
        return dataSource[index].value
    }
    func percentage(indexOf index: Int) -> CGFloat {
        let total = dataSource.reduce(0) { $0 + $1.value }
        return dataSource[index].value / total
    }
}
