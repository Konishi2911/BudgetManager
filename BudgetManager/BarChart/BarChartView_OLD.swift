//
//  BarChartView_OLD.swift
//  BudgetManager
//
//  Created by Kohei KONISHI on 2020/12/11.
//

import Cocoa

@IBDesignable
public class BarChartView_OLD: NSView {
    /// Chart type
    enum ChartType {
        /// Configure the chart as single bar chart. This is the default chart type.
        case standard
        
        /// Configure the chart as stacked bar chart.
        case stacked
        
        /// Configure the chart as grouped bar chart.
        case grouped
    }
    
    // MARK: - View Property
    @IBInspectable
    var backgroundColor: NSColor = .clear
    
    // MARK: -Externally Configurable Properties
    
    /// Color set for the Bar.
    @IBInspectable
    var barColorsSet: [NSColor] = [
        #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    ]
    
    private var prevDatasource: BarChartDataSource?
    var dataSource: BarChartDataSource? {
        didSet {
            self.prevDatasource = oldValue
            self.needsDisplay = true
        }
    }
    
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
    
    /// whether to show tics. Default to `true`.
    @IBInspectable
    var isShownTics: Bool = true
        
    /// y - Range
    var yRange: Range<CGFloat>? = nil
    private var _yRange: Range<CGFloat> {
        if let range = self.yRange { return range }
        else {
            guard let _dataSource = self.dataSource else { return 0..<0 }
            let max = CGFloat(_dataSource.max)
            let digits = self._digits(max)
            let upperBound = ceil( max / pow(10.0, CGFloat(digits)) ) * pow(10.0, CGFloat(digits))
            return 0 ..< (upperBound != 0.0 ? upperBound : 1.0)
        }
    }
    
    
    // MARK: Chart
    private let topMargine: CGFloat = 20
    
    /// The chart type. Default to `.standard`
    var chartType: BarChartView_OLD.ChartType = .standard
    
    /// The width of Bar
    @IBInspectable
    var barWidth: CGFloat = 5.0
    
    // MARK: Labels
    
    @IBInspectable
    var labelColor: NSColor = .textBackgroundColor
    
    /// Labels' font whose point of size default to 13.
    @IBInspectable
    var labelFont: NSFont = NSFont.labelFont(ofSize: 13)
    
    var numberFormatter: NumberFormatter = .init()
    
    // MARK: - Constants
    
    let xLabelHeight: CGFloat = 50
    let yLabelWidth: CGFloat = 60

    
    // MARK: - Properties
    
    @IBOutlet weak var _baseView: NSView! {
        didSet {
            _baseView.frame = bounds
            addSubview(_baseView)
        }
    }
    
    // MARK: - Initializers
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.layerContentsRedrawPolicy = .beforeViewResize
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
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
        guard let _dataSource = self.dataSource else { return }
        
        self.layer?.backgroundColor = self.backgroundColor.cgColor
                
        let chartOrigin = CGPoint(x: self.yLabelWidth, y: xLabelHeight)
        let chartAreaSize = CGSize(
            width: self.bounds.width - self.yLabelWidth,
            height: self.bounds.height - self.xLabelHeight - self.topMargine
        )
        
        
        let chartLayerManager = ChartLayerManager(
            datasource: _dataSource,
            prevDatasource: self.prevDatasource,
            colorSet: self.barColorsSet,
            chartArea: CGRect(origin: chartOrigin, size: chartAreaSize),
            yRange: self._yRange,
            barWidth: self.barWidth,
            clusterSize: UInt(_dataSource.groupSize),
            chartType: self.chartType
        )
        let axisLayerManager = AxisLineLayerManager(
            axisArea: self.bounds,
            chartArea: CGRect(origin: chartOrigin, size: chartAreaSize),
            showYTics: true,
            ticsLength: 5,
            showYGrids: true,
            yInterval: nil,
            yRange: self._yRange,
            axisColor: self.axisColor.cgColor,
            gridColor: self.gridColor.cgColor
        )
        
        let labelLayerManager = AxisLabelLayerManager(
            numberFormatter: self.numberFormatter,
            axisArea: self.bounds,
            chartArea: CGRect(origin: chartOrigin, size: chartAreaSize),
            yInterval: nil,
            yRange: self._yRange,
            numberOfDataCluster: UInt(_dataSource.numberOfDataClusters),
            labelFont: self.labelFont,
            labelColor: self.labelColor.cgColor,
            xLabelSource: _dataSource.dataLabels
        )
        
        self._clearChart()
            
        for axisLayer in axisLayerManager.layers() {
            self.layer?.addSublayer(axisLayer)
        }
        for barLayer in chartLayerManager.layer() {
            self.layer?.addSublayer(barLayer)
        }
        self.layer?.addSublayer(
            labelLayerManager.xLabelLayer()
        )
        self.layer?.addSublayer(labelLayerManager.yLabelLayer())
    }
    
    // MARK: - Private Helpers
    
    private func _digits(_ value: CGFloat) -> Int {
        guard value >= 0 else { return -1 }
        
        var digits = 0
        var _value = value
        while _value >= 10 {
            _value /= 10.0
            digits += 1
        }
        return digits
    }
    
    /// Returns `CGColor` from the given number.
    private func _getColor(fromNumber number: Int) -> CGColor {
        let numberOfColors = barColorsSet.count
        return barColorsSet[number % numberOfColors].cgColor
    }
    
    /// Clear all chart elements.
    private func _clearChart() {
        guard let subLayers = self.layer?.sublayers else { return }
        for subLayer in subLayers {
            subLayer.removeFromSuperlayer()
        }
        self.layer?.sublayers?.removeAll()
    }
}

// ===--------------------------------------------------------------------------------=== //
// MARK: - Chart Layer Manager

fileprivate struct ChartLayerManager {
    typealias ValuesByALabel = [CGFloat]
    
    /// Datasource
    let datasource: BarChartDataSource
    let prevDatasource: BarChartDataSource?
    
    /// Color set of charts
    let colorSet: [NSColor]
    
    /// Size of chart area.
    let chartArea: CGRect
    
    /// Y-Range
    let yRange: Range<CGFloat>
    
    let barWidth: CGFloat
    
    /// The number of elements in a cluster. Default to 1.
    /// - Note: This property will be ignored unless `ChartType` is `.stacked` and `.grouped`.
    var clusterSize: UInt = 1
    
    /// The chart type. Default to `.standard`
    var chartType: BarChartView_OLD.ChartType = .standard
    
    /// Radius of bar edge round
    var edgeRadius: CGFloat = 3
    
    /// Indicated whether label collection was changed.
    private var isXAxisDidChange: Bool {
        // FIXME: Continuous Animation is Disabled.
        // The animation doesn't work correctly due to difference of previous chart scale and current it.
        
        guard let _prev = self.prevDatasource else { return true }
        return true
        //return self.datasource.dataLabels.count != _prev.dataLabels.count
    }
    
    /// Returns bar shape layers from given datasource.
    /// - Parameter dataSources: The collection of data source. The count of this collection must be equal to `self.clusterSize`.
    /// - Returns: The collection od bar shape layers about each category.
    func layer() -> [CAShapeLayer] {
        var layers = [CAShapeLayer]()
        
        var elementNo: Int = 0
        if self.isXAxisDidChange {
            for source in self.datasource.dataTable {
                layers.append(self.barLayer(
                    sourceTableValue: source,
                    prevTableValue: nil,
                    elementNo: elementNo
                ))
                elementNo += 1
            }
        } else {
            for source in zip(self.datasource.dataTable, self.prevDatasource!.dataTable) {
                layers.append(self.barLayer(
                    sourceTableValue: source.0,
                    prevTableValue: source.1,
                    elementNo: elementNo
                ))
                elementNo += 1
            }
        }
        
        return layers
    }
        
    private func barLayer(sourceTableValue: ValuesByALabel,
                          prevTableValue: ValuesByALabel?,
                          elementNo: Int) -> CAShapeLayer {
        let barShape = CGMutablePath()
        let barArrangeManager = BarArrangementManager(
            chartArea: self.chartArea,
            numberOfCluster: sourceTableValue.count,
            clusterSize: self.clusterSize,
            yRange: self.yRange,
            barWidth: self.barWidth
        )
        
        var _barElementLayer: [CAShapeLayer] = []
        var clusterNo: Int = 0
        for index in 0 ..< sourceTableValue.count {
            let radius = barArrangeManager.scale(sourceTableValue[index]) >= 2 * self.edgeRadius
                ? self.edgeRadius
                : 0.5 * barArrangeManager.scale(sourceTableValue[index])
            
            let rect = CGRect(
                x: barArrangeManager.xOrigin(
                    ofElement: elementNo,
                    inClusterNo: clusterNo
                ),
                y: 0,
                width: self.barWidth,
                height: barArrangeManager.scale(sourceTableValue[index])
            )
            barShape.addRoundedRect(
                in: rect,
                cornerWidth: radius,
                cornerHeight: radius
            )
            clusterNo += 1
            
            let tempLayer = CAShapeLayer()
            tempLayer.path = barShape
            tempLayer.fillColor = self.getColor_(fromNumber: elementNo)
            tempLayer.frame = self.chartArea
            tempLayer.add(
                self.appearingAnimation(
                    endRect: rect,
                    prevScaledValue: barArrangeManager.scale(prevTableValue?[index] ?? 0.0)
                ),
                forKey: nil
            )
            _barElementLayer.append(tempLayer)
        }
        
        let barLayer = CAShapeLayer()
        for sub in _barElementLayer {
            barLayer.addSublayer(sub)
        }
        return barLayer
    }
    
    // MARK:  Animations
    
    private func appearingAnimation(endRect: CGRect, prevScaledValue: CGFloat? = nil) -> CABasicAnimation {
        let startPath = CGPath(
            rect: CGRect(
                origin: endRect.origin,
                size: CGSize(
                    width: endRect.width,
                    height: prevScaledValue ?? 0.0
                )
            ),
            transform: nil
        )
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        animation.fromValue = startPath
        animation.toValue = CGPath(rect: endRect, transform: nil)
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        return animation
    }
    
    /// Returns `CGColor` from the given number.
    private func getColor_(fromNumber number: Int) -> CGColor {
        let numberOfColors = self.colorSet.count
        return self.colorSet[number % numberOfColors].cgColor
    }
}

fileprivate struct BarArrangementManager {
    let chartArea: CGRect
    let numberOfCluster: Int
    let clusterSize: UInt
    let yRange: Range<CGFloat>
    let barWidth: CGFloat
    
    var interval: CGFloat {
        self.chartArea.width / CGFloat(self.numberOfCluster)
    }
    var clusterWidth: CGFloat {
        self.barWidth * CGFloat(self.clusterSize)
    }
    
    /// The origin on x axis for drawing the bar chart.
    func xOrigin(ofElement elementNo: Int, inClusterNo clusterNo: Int) -> CGFloat {
        precondition(self.numberOfCluster > elementNo)
        return (0.5 + CGFloat(clusterNo)) * self.interval
            - 0.5 * clusterWidth + barWidth * CGFloat(elementNo)
    }
    
    /// Scales value from reference data to value on ChartLayer Coordinate.
    func scale(_ value: CGFloat) -> CGFloat {
        guard self.yRange.upperBound != 0 else { return 0.0 }
        return self.chartArea.height / (self.yRange.upperBound - self.yRange.lowerBound) * CGFloat(value)
    }
}

// MARK: - Axis Line Layer Manager
fileprivate struct AxisLineLayerManager {
    
    // MARK: - Properties
    
    /// The size of axis line layer as the origin is x: 0, y: 0.
    let axisArea: CGRect
    
    /// The size of chart area as the origin is axis layer.
    let chartArea: CGRect
    
    /// Whether to show the Y-Tics. Default to `true`
    var showYTics: Bool = true
    
    var ticsLength: CGFloat = 10
    
    /// Whether to show the y-Grids. Default to `false`
    var showYGrids: Bool = false
    
    /// The interval of y-Tics. `nil` will be auto. Default to `nil`
    var yInterval: CGFloat?
    
    /// y range.
    var yRange: Range<CGFloat>
    
    var axisColor: CGColor = NSColor.systemGray.cgColor
    var gridColor: CGColor = NSColor.lightGray.cgColor

    // MARK: - Getting Axis Line Layer and Grid Layer
    
    func layers() -> [CAShapeLayer] {
        let axisPaths = CGMutablePath()
        let gridPaths = CGMutablePath()
        
        axisPaths.addPath(self.xAxisLine)
        axisPaths.addPath(self.yAxisLine)
        if self.showYTics { axisPaths.addPath(self.yTics) }
        let axisLayer = CAShapeLayer()
        axisLayer.path = axisPaths
        axisLayer.strokeColor = self.axisColor
        axisLayer.frame = self.axisArea
        
        if self.showYGrids { gridPaths.addPath(self.grids) }
        let gridLayer = CAShapeLayer()
        gridLayer.path = gridPaths
        gridLayer.strokeColor = self.gridColor
        gridLayer.frame = self.axisArea
        
        return [axisLayer, gridLayer]
    }
    
    // MARK: - Private Helpers
    
    /// The actual interval od y-Tics.
    private var _yInterval: CGFloat {
        if let interval = self.yInterval {
            return interval
        } else {
            return yRange.upperBound / 4
        }
    }
 
    private var xAxisLine: CGMutablePath {
        let line = CGMutablePath()
        line.move(to: self.chartArea.origin)
        line.addLine(to: CGPoint(x: self.chartArea.maxX, y: self.chartArea.origin.y))
        
        return line
    }
    private var yAxisLine: CGMutablePath {
        let line = CGMutablePath()
        line.move(to: self.chartArea.origin)
        line.addLine(to: CGPoint(x: self.chartArea.origin.x, y: self.chartArea.maxY))
        
        return line
    }
    private var yTics: CGMutablePath {
        let line = CGMutablePath()
        guard yRange.upperBound != 0 else { return line }
        
        var counter: Int = 1
        while yRange.upperBound >= CGFloat(counter) * _yInterval {
            let offset = CGFloat(counter) * self.scale_(_yInterval)
            line.move(to: CGPoint(x: self.chartArea.origin.x,
                                  y: self.chartArea.origin.y + offset))
            line.addLine(to: CGPoint(x: self.chartArea.origin.x + self.ticsLength,
                                     y: self.chartArea.origin.y + offset))
            counter += 1
        }
        return line
    }
    private var grids: CGMutablePath {
        let line = CGMutablePath()
        guard yRange.upperBound != 0 else { return line }
        
        var counter: Int = 1
        while yRange.upperBound >= CGFloat(counter) * _yInterval {
            let offset = CGFloat(counter) * self.scale_(_yInterval)
            line.move(to: CGPoint(x: self.chartArea.origin.x,
                                  y: self.chartArea.origin.y + offset))
            line.addLine(to: CGPoint(x: self.chartArea.maxX,
                                     y: self.chartArea.origin.y + offset))
            counter += 1
        }
        return line.copy(dashingWithPhase: 10, lengths: [2]) as! CGMutablePath
    }
    
    /// Scales value from reference data to value on ChartLayer Coordinate.
    private func scale_(_ value: CGFloat) -> CGFloat {
        guard self.yRange.upperBound != 0 else { return 0.0 }
        return self.chartArea.height / (self.yRange.upperBound - self.yRange.lowerBound) * CGFloat(value)
    }
}

// MARK: - Axis Label Layer Manager

fileprivate struct AxisLabelLayerManager {
    private let margine: CGFloat = 5
    
    // MARK: - Properties
    
    /// Format of y-label numbers.
    let numberFormatter: NumberFormatter
    
    /// The size of axis line layer as the origin is x: 0, y: 0.
    let axisArea: CGRect
    
    /// The size of chart area as the origin is axis layer.
    let chartArea: CGRect
    
    /// The interval of y-Tics. `nil` will be auto. Default to `nil`
    var yInterval: CGFloat?
    
    /// y range.
    var yRange: Range<CGFloat>
        
    /// The number of data clusters.
    let numberOfDataCluster: UInt
    
    /// Font
    var labelFont: NSFont
    
    var labelColor: CGColor
    
    let xLabelSource: [String]
    
    var xlabelHeight: CGFloat {
        self.xLabelSource.map {
            ($0 as NSString).size(
                withAttributes: [NSAttributedString.Key.font : self.labelFont]
            ).height
        }.max()!
    }
    var ylabelWidth: CGFloat {
        "\(yRange.upperBound)".size(
            withAttributes: [NSAttributedString.Key.font : self.labelFont]
        ).height
    }
    
    func xLabelLayer() -> CALayer {
        let superLayer = CALayer()
        
        var counter = 0
        for labelString in self.xLabelSource {
            let textLayer = CATextLayer()
            let textSize = (labelString as NSString).size(withAttributes: [.font: self.labelFont])
            
            textLayer.string = labelString
            textLayer.font = self.labelFont
            textLayer.fontSize = self.labelFont.pointSize
            textLayer.foregroundColor = self.labelColor
            textLayer.alignmentMode = .center
            textLayer.allowsFontSubpixelQuantization = true
            textLayer.frame = CGRect(
                x: chartArea.minX + xTitlePosition(indexOf: counter, textWidth: textSize.width),
                y: chartArea.minY - margine - textSize.height,
                width: textSize.width,
                height: textSize.height
            )
            
            superLayer.addSublayer(textLayer)
            
            counter += 1
        }
        return superLayer
    }
    
    func yLabelLayer() -> CALayer {
        let superLayer = CALayer()
        
        var counter: Int = 1
        while yRange.upperBound >= CGFloat(counter) * self._yInterval {
            let textLayer = CATextLayer()
            let offset = CGFloat(counter) * self.scale_(self._yInterval)
            
            let labelString = numberFormatter.string(
                from: (self._yInterval * CGFloat(counter)) as NSNumber
            )!
            let textSize = (labelString as NSString?)!.size(withAttributes: [.font: self.labelFont])

            textLayer.string = labelString
            textLayer.font = self.labelFont
            textLayer.fontSize = self.labelFont.pointSize
            textLayer.foregroundColor = self.labelColor
            textLayer.alignmentMode = .right
            textLayer.allowsFontSubpixelQuantization = true
            textLayer.frame = CGRect(
                x: 0,
                y: chartArea.origin.y + offset - 0.5 * textSize.height,
                width: chartArea.minX - self.margine,
                height: textSize.height
            )
            
            superLayer.addSublayer(textLayer)
            
            counter += 1
        }
        return superLayer
    }
    
    /// The actual interval od y-Tics.
    private var _yInterval: CGFloat {
        if let interval = self.yInterval {
            return interval
        } else {
            return yRange.upperBound / 4
        }
    }
    
    /// Scales value from reference data to value on ChartLayer Coordinate.
    private func scale_(_ value: CGFloat) -> CGFloat {
        guard self.yRange.upperBound != 0 else { return 0.0 }
        return self.chartArea.height / (self.yRange.upperBound - self.yRange.lowerBound) * CGFloat(value)
    }
    
    var _xInterval: CGFloat {
        self.chartArea.width / CGFloat(self.numberOfDataCluster)
    }
    
    /// The central position of the title text.
    func xTitlePosition(indexOf clusterNo: Int, textWidth: CGFloat) -> CGFloat {
        precondition(self.numberOfDataCluster > clusterNo)
        
        return self._xInterval * (0.5 + CGFloat(clusterNo)) - 0.5 * textWidth
    }
}
