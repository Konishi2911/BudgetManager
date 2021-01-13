//
//  BarChartView.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/11/19.
//

import Cocoa

@IBDesignable
public class BarChartView: NSView {
    @IBOutlet var _baseView: NSView! {
        didSet {
            self.frame = _baseView.bounds
            self.addSubview(_baseView)
        }
    }
    @IBOutlet weak var titleField: NSTextField!
    @IBOutlet private weak var chartView: _BCChartView!
    @IBOutlet private weak var yLabelView: _BCYLabelView!
    @IBOutlet private weak var xLabelView: _BCXLabelView!
    
    // MARK: - View Property
    @IBInspectable
    var backgroundColor: NSColor = .clear

    private var datasourceContainer: _BCDatasourceContainer!
    var dataSource: BarChartDataSource! {
        didSet {
            self.datasourceContainer = .init(datasource: self.dataSource)
            self.needsDisplay = true
        }
    }
    
    // MARK: Title
    var titleString: String = "Title"
    var titleFont: NSFont = .titleBarFont(ofSize: 28)
    
    // MARK: Chart
    var barColorList: [NSColor] = [
        #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    ]
    
    @IBInspectable
    var barWidth: CGFloat = 20
    
    @IBInspectable
    var barEdgeWidth: CGFloat = 3
    
    @IBInspectable
    var numberOfYTics: Int = 4
    
    // MARK: Axis
    /// Axis color.
    @IBInspectable
    var axisColor: NSColor = NSColor.systemGray
    
    /// Grid color.
    @IBInspectable
    var gridColor: NSColor = NSColor.lightGray
    
    /// Whether to show grid. Default to `false`.
    @IBInspectable
    var isShownGrid: Bool = false
    
    var ticsWidth: CGFloat = 5
    
    /// whether to show tics. Default to `true`.
    @IBInspectable
    var isShownTics: Bool = true
    
    // MARK: Labels Related
    var numberFormatter: NumberFormatter = .init()
    
    // MARK: Labels
    var xLabelFont: NSFont = .labelFont(ofSize: 14)
    var yLabelFont: NSFont = .labelFont(ofSize: 12)
    
    @IBInspectable
    var yLabelColor: NSColor = .labelColor
    
    @IBInspectable
    var xLabelColor: NSColor = .labelColor
    
    
    // MARK: - Initializers
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.loadNib()
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.loadNib()
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    private func loadNib() {
        if let _nib = NSNib(nibNamed: "BarChartView", bundle: nil) {
            _nib.instantiate(withOwner: self, topLevelObjects: nil)
        }
    }
    
    // MARK: For Interface Builder
    public override func prepareForInterfaceBuilder() {
        self.dataSource = BarChartDataSource(
            groupSize: 2,
            dataLabels: ["A", "B"],
            dataSource: { (i: Int) -> BarChartData in
            return BarChartData(groupName: "Group \(i + 1)", values: [CGFloat(i + 1) * 1.0, CGFloat(i + 1) * 3.0])
        })
    }
    
    // MARK: - UI Methods
    
    public override var wantsUpdateLayer: Bool { return true }
    public override func updateLayer() {
        let geometryManager: _BCGeometryManager = .init(
            datasourceContainer: self.datasourceContainer,
            chartAreaSize: self.chartView.bounds.size,
            barWidth: self.barWidth,
            barEdgeRadius: self.barEdgeWidth,
            numberOfYTics: self.numberOfYTics
        )
        
        titleField.stringValue = self.titleString
        
        chartView.chartGeometryManager = geometryManager
        chartView.chartColorList = self.barColorList
        chartView.yTicsWidth = self.ticsWidth
        chartView.axisColor = self.axisColor
        chartView.gridColor = self.gridColor
        
        xLabelView.chartGeometryManager = geometryManager
        xLabelView.labelColor = self.xLabelColor
        xLabelView.labelFont = self.xLabelFont
        
        yLabelView.chartGeometryManager = geometryManager
        yLabelView.labelColor = self.yLabelColor
        yLabelView.labelFont = self.yLabelFont
        
        chartView.needsDisplay = true
        xLabelView.needsDisplay = true
        yLabelView.needsDisplay = true
    }
}


// MARK: - Chart View
@IBDesignable
class _BCChartView: NSView {
    
    // MARK: Appearances
    var backgroundColor: NSColor = .clear
    var chartColorList: [NSColor]!
    var axisColor: NSColor!
    var gridColor: NSColor!
    
    // MARK: Geometries
    var yTicsWidth: CGFloat!
    var chartGeometryManager: _BCGeometryManager! {
        didSet {
            if let manager = oldValue {
                self.prevChartGeometryManager = manager
            }
            self.needsLayout = true
        }
    }
    private var prevChartGeometryManager: _BCGeometryManager?
    private var isContinuos: Bool {
        if let pManager = self.prevChartGeometryManager {
            return self.chartGeometryManager.datasource.numberOfDataClusters
                == pManager.datasource.numberOfDataClusters
        } else {
            return false
        }
    }
    
    // MARK: Datasource Related
    var datasource: BarChartDataSource {
        self.chartGeometryManager.datasource
    }
    
    // MARK: - Initializers
    public override var wantsUpdateLayer: Bool { true }
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let datasource = BarChartDataSource(
            groupSize: 2,
            dataLabels: ["A", "B"],
            dataSource: { (i: Int) -> BarChartData in
            return BarChartData(groupName: "Group \(i + 1)", values: [CGFloat(i + 1) * 1.0, CGFloat(i + 1) * 3.0])
        })
        
        self.chartGeometryManager = .init(
            datasourceContainer: _BCDatasourceContainer(datasource: datasource),
            chartAreaSize: self.bounds.size,
            barWidth: 10,
            barEdgeRadius: 3,
            numberOfYTics: 4
        )
    }
    
    // MARK: - View Lifecycles
    public override func updateLayer() {
        self.layer?.actions = [
            #keyPath(CAShapeLayer.frame): NSNull(),
            #keyPath(CAShapeLayer.bounds): NSNull()
        ]
        
        self._clearChart()
        self.layer?.addSublayer(self.axisLayer())
        self.layer?.addSublayer(self.barLayer())
    }
    /// Clear all chart elements.
    private func _clearChart() {
        guard let subLayers = self.layer?.sublayers else { return }
        for subLayer in subLayers {
            subLayer.removeFromSuperlayer()
        }
        self.layer?.sublayers?.removeAll()
    }
    
    // MARK: - Axis and Grid
    
    private var xAxisLine: CGMutablePath {
        let line = CGMutablePath()
        line.move(to: .zero)
        line.addLine(to: CGPoint(
            x: self.chartGeometryManager.chartAreaSize.width,
            y: .zero
        ))
        
        return line
    }
    private var yAxisLine: CGMutablePath {
        let line = CGMutablePath()
        line.move(to: .zero)
        line.addLine(to: CGPoint(
            x: .zero,
            y: self.chartGeometryManager.chartAreaSize.height
        ))

        return line
    }
    private var yTicsLine: CGMutablePath {
        let line = CGMutablePath()
        guard self.chartGeometryManager.yRange.upperBound != 0 else { return line }
        
        let _yInterval = self.chartGeometryManager.yInterval
        let _yMax = self.chartGeometryManager.yRange.upperBound
        
        var counter: Int = 0
        while _yMax >= Double(counter) * _yInterval {
            line.move(
                to: CGPoint(
                    x: .zero,
                    y: self.chartGeometryManager.yCenter(counter)
                )
            )
            line.addLine(
                to: CGPoint(
                    x: self.yTicsWidth,
                    y: self.chartGeometryManager.yCenter(counter)
                )
            )
            counter += 1
        }
        return line
    }
    private var grids: CGMutablePath {
        let line = CGMutablePath()
        guard self.chartGeometryManager.yRange.upperBound != 0 else { return line }
        
        let _yInterval = self.chartGeometryManager.yInterval
        let _yMax = self.chartGeometryManager.yRange.upperBound
        
        var counter: Int = 0
        while _yMax >= Double(counter) * _yInterval {
            line.move(
                to: CGPoint(
                    x: .zero,
                    y: self.chartGeometryManager.yCenter(counter)
                )
            )
            line.addLine(
                to: CGPoint(
                    x: self.chartGeometryManager.chartAreaSize.width,
                    y: self.chartGeometryManager.yCenter(counter)
                )
            )
            counter += 1
        }
        return line.copy(dashingWithPhase: 10, lengths: [2]) as! CGMutablePath
    }
    
    private func xAxisLayer() -> CAShapeLayer {
        let layer: CAShapeLayer = .init()
        layer.path = self.xAxisLine
        layer.strokeColor = self.axisColor.cgColor
        
        return layer
    }
    private func yAxisLayer() -> CAShapeLayer {
        let layer: CAShapeLayer = .init()
        layer.path = self.yAxisLine
        layer.strokeColor = self.axisColor.cgColor

        return layer
    }
    private func yTicsLayer() -> CAShapeLayer {
        let layer: CAShapeLayer = .init()
        layer.path = self.yTicsLine
        layer.strokeColor = self.gridColor.cgColor

        return layer
    }
    private func gridsLayer() -> CAShapeLayer {
        let layer: CAShapeLayer = .init()
        layer.path = self.grids
        layer.strokeColor = self.gridColor.cgColor

        return layer
    }
    
    private func axisLayer() -> CALayer {
        let layer = CALayer()
        
        layer.addSublayer(self.xAxisLayer())
        layer.addSublayer(self.yAxisLayer())
        layer.addSublayer(self.yTicsLayer())
        layer.addSublayer(self.gridsLayer())
        
        return layer
    }
    
    // MARK: - Bar
    
    private func barLayer() -> CALayer {
        let layer: CALayer = .init()
        for groupNo in 0 ..< self.datasource.dataTable.count {
            layer.addSublayer(self.barLayer(groupNo: groupNo))
        }
    
        return layer
    }
    private func barLayer(groupNo: Int) -> CAShapeLayer {
        let sourceTable = self.datasource.dataTable
        let sourceValues = sourceTable[groupNo]
        
        var _barElementLayer: [CAShapeLayer] = []
        
        for index in 0 ..< sourceValues.count {
            let barHeight = self.chartGeometryManager.scale(sourceValues[index])
            let radius = barHeight >= 2 * self.chartGeometryManager.barEdgeRadius
                ? self.chartGeometryManager.barEdgeRadius
                : 0.5 * barHeight
            
            let rect = CGRect(
                x: self.chartGeometryManager.barLeadingPosition(index, groupNo: groupNo),
                y: 0,
                width: self.chartGeometryManager.barWidth,
                height: barHeight
            )
            
            let barShape = CGMutablePath()
            barShape.addRoundedRect(
                in: rect,
                cornerWidth: radius,
                cornerHeight: radius
            )
            
            let singleBarLayer = CAShapeLayer()
            singleBarLayer.path = barShape
            singleBarLayer.fillColor = self.getColor_(fromNumber: groupNo)
            singleBarLayer.frame = CGRect(
                origin: .zero,
                size: self.chartGeometryManager.chartAreaSize
            )
            
            
            let animationManager: _BCAnimationManager
            if self.isContinuos {
                animationManager = .init(
                    prevGeometryManager: self.prevChartGeometryManager,
                    currentGeometryManager: self.chartGeometryManager
                )
            } else {
                animationManager = .init(
                    prevGeometryManager: nil,
                    currentGeometryManager: self.chartGeometryManager
                )
            }
            singleBarLayer.add(
                animationManager.barAnimation(index: index, barGroupNo: groupNo),
                forKey: nil)
            
            _barElementLayer.append(singleBarLayer)
        }
        
        let barLayer = CAShapeLayer()
        for sub in _barElementLayer {
            barLayer.addSublayer(sub)
        }
        
        return barLayer
    }
    
    /// Returns `CGColor` from the given number.
    private func getColor_(fromNumber number: Int) -> CGColor {
        let numberOfColors = self.chartColorList.count
        return self.chartColorList[number % numberOfColors].cgColor
    }
}

// ===--------------------------------------------------------------------------------=== //
//MARK: - Y-Label View
@IBDesignable
class _BCYLabelView: NSView {
    // MARK: Appearances
    var backgroundColor: NSColor = .clear
    var labelColor: NSColor!
    
    var labelFont: NSFont!
    
    // MARK: Geometries
    var chartGeometryManager: _BCGeometryManager! {
        didSet {
            if let manager = oldValue {
                self.prevChartGeometryManager = manager
            }
            self.needsLayout = true
        }
    }
    private var prevChartGeometryManager: _BCGeometryManager?
    private var isContinuos: Bool {
        if let pManager = self.prevChartGeometryManager {
            return self.chartGeometryManager.datasource.numberOfDataClusters
                == pManager.datasource.numberOfDataClusters
        } else {
            return false
        }
    }
    
    // MARK: Datasource Related
    var numberFormatter: NumberFormatter = .init()
    var datasource: BarChartDataSource {
        self.chartGeometryManager.datasource
    }
    
    // MARK: - Initializers
    public override var wantsUpdateLayer: Bool { true }
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let datasource = BarChartDataSource(
            groupSize: 2,
            dataLabels: ["A", "B"],
            dataSource: { (i: Int) -> BarChartData in
            return BarChartData(groupName: "Group \(i + 1)", values: [CGFloat(i + 1) * 1.0, CGFloat(i + 1) * 3.0])
        })
        
        self.chartGeometryManager = .init(
            datasourceContainer: _BCDatasourceContainer(datasource: datasource),
            chartAreaSize: self.bounds.size,
            barWidth: 10,
            barEdgeRadius: 3,
            numberOfYTics: 4
        )
    }
    
    // MARK: - View Lifecycles
    public override func updateLayer() {
        self._clearChart()
        self.layer?.addSublayer(self.labelsLayer())
    }
    /// Clear all chart elements.
    private func _clearChart() {
        guard let subLayers = self.layer?.sublayers else { return }
        for subLayer in subLayers {
            subLayer.removeFromSuperlayer()
        }
        self.layer?.sublayers?.removeAll()
    }
    
    // MARK: - Label Text Layers
    private func labelsLayer() -> CALayer {
        let layer = CALayer()
        for index in 0 ..< self.chartGeometryManager.numberOfYTics {
            layer.addSublayer(self.labelLayer(ticNo: index))
        }
        
        return layer
    }
    private func labelLayer(ticNo: Int) -> CATextLayer {
        let labelNumber = NSNumber(value: self.chartGeometryManager.yValue(ticsNo: ticNo))
        let labelString = self.numberFormatter.string(from: labelNumber)!
        let textSize = (labelString as NSString).size(withAttributes: [.font: self.labelFont as Any])
        
        let textLayer = CATextLayer()
        textLayer.string = labelString
        textLayer.alignmentMode = .right
        textLayer.font = self.labelFont
        textLayer.fontSize = self.labelFont.pointSize
        textLayer.foregroundColor = self.labelColor.cgColor
        textLayer.frame = CGRect(
            x: .zero,
            y: self.chartGeometryManager.yCenter(ticNo),
            width: self.bounds.width,
            height: textSize.height
        )
        
        return textLayer
    }
}

// ===--------------------------------------------------------------------------------=== //
//MARK: - X-Label View
@IBDesignable
class _BCXLabelView: NSView {
    // MARK: Appearances
    var backgroundColor: NSColor = .clear
    var labelColor: NSColor!
    
    var labelFont: NSFont!
    
    // MARK: Geometries
    var yTicsWidth: CGFloat!
    var chartGeometryManager: _BCGeometryManager! {
        didSet {
            if let manager = oldValue {
                self.prevChartGeometryManager = manager
            }
            self.needsLayout = true
        }
    }
    private var prevChartGeometryManager: _BCGeometryManager?
    private var isContinuos: Bool {
        if let pManager = self.prevChartGeometryManager {
            return self.chartGeometryManager.datasource.numberOfDataClusters
                == pManager.datasource.numberOfDataClusters
        } else {
            return false
        }
    }
    
    // MARK: Datasource Related
    var numberFormatter: NumberFormatter!
    var datasource: BarChartDataSource {
        self.chartGeometryManager!.datasource
    }
    
    // MARK: - Initializers
    public override var wantsUpdateLayer: Bool { true }
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        let datasource = BarChartDataSource(
            groupSize: 2,
            dataLabels: ["A", "B"],
            dataSource: { (i: Int) -> BarChartData in
            return BarChartData(groupName: "Group \(i + 1)", values: [CGFloat(i + 1) * 1.0, CGFloat(i + 1) * 3.0])
        })
        
        self.chartGeometryManager = .init(
            datasourceContainer: _BCDatasourceContainer(datasource: datasource),
            chartAreaSize: self.bounds.size,
            barWidth: 10,
            barEdgeRadius: 3,
            numberOfYTics: 4
        )
    }
    
    // MARK: - View Lifecycles
    public override func updateLayer() {
        self._clearChart()
        self.layer?.addSublayer(self.labelsLayer())
    }
    /// Clear all chart elements.
    private func _clearChart() {
        guard let subLayers = self.layer?.sublayers else { return }
        for subLayer in subLayers {
            subLayer.removeFromSuperlayer()
        }
        self.layer?.sublayers?.removeAll()
    }
    
    // MARK: - Label Text Layers
    private func labelsLayer() -> CALayer {
        let layer = CALayer()
        for index in 0 ..< self.datasource.dataLabels.count {
            layer.addSublayer(self.labelLayer(index: index))
        }
        
        return layer
    }
    private func labelLayer(index: Int) -> CATextLayer {
        let labelString = self.datasource.dataLabels[index]
        let textSize = (labelString as NSString).size(withAttributes: [.font: self.labelFont as Any])
        
        let textLayer = CATextLayer()
        textLayer.string = labelString
        textLayer.alignmentMode = .center
        textLayer.font = self.labelFont
        textLayer.fontSize = self.labelFont.pointSize
        textLayer.foregroundColor = self.labelColor.cgColor
        textLayer.frame = CGRect(
            x: self.chartGeometryManager!.xCenter(index) - 0.5 * textSize.width,
            y: .zero,
            width: textSize.width,
            height: self.bounds.height
        )
        
        return textLayer
    }
}

// ===--------------------------------------------------------------------------------=== //
// MARK: - Datasource Container
struct _BCDatasourceContainer {
    let datasource: BarChartDataSource
    
    init(datasource: BarChartDataSource) {
        self.datasource = datasource
        
        let max = self.datasource.max
        let digits = Self._digits(max)
        let upperBound = ceil( max / pow(10.0, Double(digits)) ) * pow(10.0, Double(digits))
        self.yRange = 0 ..< (upperBound != 0.0 ? upperBound : 1.0)
    }
    
    // MARK: - Calculated y Values
    private(set) var yRange: Range<Double>
    
    private static func _digits(_ value: Double) -> Int {
        guard value >= 0 else { return -1 }
        
        var digits = 0
        var _value = value
        while _value >= 10 {
            _value /= 10.0
            digits += 1
        }
        return digits
    }
}

// ===--------------------------------------------------------------------------------=== //
// MARK: - Geometry Manager

struct _BCGeometryManager {
    let datasourceContainer: _BCDatasourceContainer
    let datasource: BarChartDataSource
    
    // MARK: Geometry Related
    let chartAreaSize: CGSize
    let barWidth: CGFloat
    let barEdgeRadius: CGFloat
    let numberOfYTics: Int
    
    init(datasourceContainer: _BCDatasourceContainer, chartAreaSize: CGSize, barWidth: CGFloat, barEdgeRadius: CGFloat, numberOfYTics: Int) {
        self.datasourceContainer = datasourceContainer
        self.chartAreaSize = chartAreaSize
        self.barWidth = barWidth
        self.barEdgeRadius = barEdgeRadius
        self.numberOfYTics = numberOfYTics
        
        self.datasource = datasourceContainer.datasource
        self.yRange = datasourceContainer.yRange
    }
    
    // MARK: - Calculated x Dimensions
    var barClusterWidth: CGFloat {
        self.barWidth * CGFloat(self.datasource.groupSize)
    }
    var xGeometryInterval: CGFloat {
        self.chartAreaSize.width / CGFloat(self.datasource.numberOfDataClusters)
    }
    
    /// Returns the x-position of leading edge of bar which passed groupNo and index specifies.
    func barLeadingPosition(_ index: Int, groupNo: Int) -> CGFloat {
        self.xCenter(index) - 0.5 * self.barClusterWidth + self.barWidth * CGFloat(groupNo)
    }
    /// Returns the x-position of center of bar cluster specified by passed index.
    func xCenter(_ index: Int) -> CGFloat {
        precondition(self.datasource.numberOfDataClusters > index)
        return self.xGeometryInterval * (0.5 + CGFloat(index))
    }
    
    // MARK: - Calculated y Values
    let yRange: Range<Double>
    var yInterval: Double {
        self.yRange.upperBound / Double(self.numberOfYTics)
    }
    func yValue(ticsNo: Int) -> Double {
        precondition(self.numberOfYTics > ticsNo)
        return self.yRange.lowerBound + Double(ticsNo) * self.yInterval
    }
    private func _digits(_ value: Double) -> Int {
        guard value >= 0 else { return -1 }
        
        var digits = 0
        var _value = value
        while _value >= 10 {
            _value /= 10.0
            digits += 1
        }
        return digits
    }
    
    // MARK: - Calculated y Dimensions
    var yGeometryInterval: CGFloat {
        chartAreaSize.height / CGFloat(self.numberOfYTics)
    }
    func yCenter(_ index: Int) -> CGFloat {
        precondition(self.datasource.numberOfDataClusters > index)
        return self.yGeometryInterval * CGFloat(index)
    }
    
    // MARK: - Converters
    func scale(_ value :Double) -> CGFloat {
        guard self.yRange.upperBound != 0 else { return 0.0 }
        return self.chartAreaSize.height / CGFloat((self.yRange.upperBound - self.yRange.lowerBound)) * CGFloat(value)
    }
    func scale(_ value :CGFloat) -> CGFloat {
        return self.scale(Double(value))
    }
}

// ===--------------------------------------------------------------------------------------=== //
// MARK: - Animation Manager
struct _BCAnimationManager {
    let prevGeometryManager: _BCGeometryManager?
    let currentGeometryManager: _BCGeometryManager
    
    func barAnimation(index: Int, barGroupNo: Int) -> CABasicAnimation {
        let prevX = prevGeometryManager?.barLeadingPosition(index, groupNo: barGroupNo)
            ?? currentGeometryManager.barLeadingPosition(index, groupNo: barGroupNo)
        let prevWidth = prevGeometryManager?.barWidth ?? currentGeometryManager.barWidth
        let prevValue = self.prevGeometryManager?.datasource.dataTable[barGroupNo][index] ?? 0
        let prevHeight = prevGeometryManager?.scale(prevValue)
            ?? currentGeometryManager.scale(prevValue)
        
        let currentValue = self.currentGeometryManager.datasource.dataTable[barGroupNo][index]

        
        let startPath = CGPath(
            rect: CGRect(
                x: prevX,
                y: 0,
                width: prevWidth,
                height: prevHeight
            ),
            transform: nil
        )
        let endPath = CGPath(
            rect: CGRect(
                x: currentGeometryManager.barLeadingPosition(index, groupNo: barGroupNo),
                y: 0,
                width: currentGeometryManager.barWidth,
                height: currentGeometryManager.scale(currentValue)
            ),
            transform: nil
        )
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        animation.fromValue = startPath
        animation.toValue = endPath
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        return animation
    }
}
