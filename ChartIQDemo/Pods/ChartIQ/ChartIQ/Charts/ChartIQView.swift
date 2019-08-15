//
//  ChartIQView.swift
//  ChartIQ
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import UIKit
import WebKit
import CoreTelephony

@objc(ChartIQDataSource)
public protocol ChartIQDataSource
{
    /// Called when chart pull initial data
    ///
    /// - Parameters:
    ///   - params: The ChartIQQuoteFeedParams
    ///   - completionHandler: The Completion Handler
    func pullInitialData(by params: ChartIQQuoteFeedParams, completionHandler: @escaping ([ChartIQData]) -> Void)
    
    /// Called when chart pull update data
    ///
    /// - Parameters:
    ///   - params: The ChartIQQuoteFeedParams
    ///   - completionHandler: The Completion Handler
    func pullUpdateData(by params: ChartIQQuoteFeedParams, completionHandler: @escaping ([ChartIQData]) -> Void)
    
    /// Called when chart pull pagination data
    ///
    /// - Parameters:
    ///   - params: The ChartIQQuoteFeedParams
    ///   - completionHandler: The Completion Handler
    func pullPaginationData(by params: ChartIQQuoteFeedParams, completionHandler: @escaping ([ChartIQData]) -> Void)
    
}

@objc(ChartIQDelegate)
public protocol ChartIQDelegate
{
    /// Called when the symbol changes
    ///
    /// - Parameters:
    ///   - chartIQView: The ChartIQView Object
    @objc func chartIQViewDidFinishLoading(_ chartIQView: ChartIQView)
    
    /// Called when the symbol changes
    ///
    /// - Parameters:
    ///   - chartIQView: The ChartIQView Object
    ///   - symbol: The symbol name
    @objc optional func chartIQView(_ chartIQView: ChartIQView, didUpdateSymbol symbol: String)
    
    /// Called when the layout changes
    ///
    /// - Parameters:
    ///   - chartIQView: The ChartIQView Object
    ///   - layout: The layout infomation
    @objc optional func chartIQView(_ chartIQView: ChartIQView, didUpdateLayout layout: Any)
    
    /// Called when a drawing is added or deleted (all the drawings are returned, not just the new one)
    ///
    /// - Parameters:
    ///   - chartIQView: The ChartIQView Object
    ///   - drawings: The drawing objects in JSON format
    @objc optional func chartIQView(_ chartIQView: ChartIQView, didUpdateDrawing drawings: Any)
}

/// Data Method
@objc
public enum ChartIQDataMethod: Int {
    case push
    case pull
}

/// Chart scale
@objc
public enum ChartIQScale: Int {
    case log
    case linear
}

/// Chart type
@objc
public enum ChartIQChartType: Int {
    case line
    case candle
    case bar
    case wave
    case colored_bar
    case colored_line
    case hollow_candle
    case volume_candle
    case scatterplot
    case baseline_delta
    case baseline_delta_mountain
    case mountain
    case colored_mountain
}

/// Aggregation type
@objc
public enum ChartIQAggregationType: Int {
    case rangebars
    case ohlc
    case kagi
    case pandf
    case heikinashi
    case linebreak
    case renko
}


/// Study error
public enum ChartIQStudyError: Error {
    case invalidInput
    case invalidOutput
    case studyNotFound
}

/// Chart drawing tool
@objc
public enum ChartIQDrawingTool: Int {
    case channel
    case continuousLine
    case doodle
    case ellipse
    case fibarc
    case fibfan
    case fibretrace
    case fibtimezone
    case gartley
    case horizontalLine
    case line
    case pitchfork
    case ray
    case rectangle
    case segment
    case verticalLine
}

/// Chart that draw ChartIQ chart.
public class ChartIQView: UIView {

    var webView: WKWebView!
    
    // MARK: - Properties
    static internal var url = ""
    static internal var refreshInterval = 0
    static internal var voiceoverFields: [String: Bool] = [:]
    
    public static var chartIQUrl: String {
        return ChartIQView.url
    }
    
    static internal var sdkVersion: String {
        if  let infos = Bundle(for: ChartIQView.self ).infoDictionary, let version = infos[kCFBundleVersionKey as String] as? String {
            return version
        }
        return ""
    }
    
    /// Quote Fields
    public enum ChartIQQuoteFields: String {
        case date = "Date"
        case close = "Close"
        case open = "Open"
        case high = "High"
        case low = "Low"
        case volume = "Volume"
    }
    
    internal var _dataMethod: ChartIQDataMethod = .push
    
    internal var drawingScript: WKUserScript {
        let source = "addDrawingListener();";
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    internal var layoutScript: WKUserScript {
        let source = "addLayoutListener()"
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }
    
    internal var studyObjects = [Study]()
    
    public var dataMethod: ChartIQDataMethod {
        return _dataMethod
    }
    
    public var dataSource: ChartIQDataSource?
    
    public var delegate: ChartIQDelegate?
    
    public var symbol: String {
        return webView.evaluateJavaScriptWithReturn("stxx.chart.symbol") ?? ""
    }
    
    public var interval: String {
        return webView.evaluateJavaScriptWithReturn("stxx.layout.interval.toString()") ?? "day"
    }
    
    internal var jsInterval: String {
        var _interval = webView.evaluateJavaScriptWithReturn("stxx.layout.interval.toString()") ?? "day"
        if Int(_interval) == nil {
            _interval = "\"" + _interval + "\""
        }
        return _interval
    }
    
    public var timeUnit: String {
        return webView.evaluateJavaScriptWithReturn("stxx.timeUnit") ?? "minute"
    }
    
    public var periodicity: Int {
        if let periodicityStr = webView.evaluateJavaScriptWithReturn("stxx.layout.periodicity.toString()"), let periodicity = Int(periodicityStr) {
            return periodicity
        }
        return 1
    }
    
    public var chartType: ChartIQChartType {
        let _type = webView.evaluateJavaScriptWithReturn("stxx.layout.chartType")
        if _type == "line" {
            return .line
        } else if _type == "candle" {
            return .candle
        } else if _type == "bar" {
            return .bar
        } else if _type == "wave" {
            return .wave
        } else if _type == "colored_bar" {
            return .colored_bar
        } else if _type == "colored_line" {
            return .colored_line
        } else if _type == "hollow_candle" {
            return .hollow_candle
        } else if _type == "volume_candle" {
            return .volume_candle
        } else if _type == "scatterplot" {
            return .scatterplot
        } else if _type == "baseline_delta" {
            return .baseline_delta
        } else if _type == "baseline_delta_mountain" {
            return .baseline_delta_mountain
        } else if _type == "mountain" {
            return .mountain
        } else if _type == "colored_mountain" {
            return .colored_mountain
        } else {
            return .bar
        }
    }
    
    public var aggregationType: ChartIQAggregationType? {
        let _type = webView.evaluateJavaScriptWithReturn("stxx.layout.aggregationType")
        if _type == "rangebars" {
            return .rangebars
        } else if _type == "ohlc" {
            return .ohlc
        } else if _type == "kagi" {
            return .kagi
        } else if _type == "pandf" {
            return .pandf
        } else if _type == "heikinashi" {
            return .heikinashi
        } else if _type == "linebreak" {
            return .linebreak
        } else if _type == "renko" {
            return .renko
        } else {
            return nil
        }
    }
    
    public var scale: ChartIQScale {
        let _scale = webView.evaluateJavaScriptWithReturn("stxx.layout.chartScale")
        if _scale == "log" {
            return .log
        } else {
            return .linear
        }
    }
    
    fileprivate enum ChartIQCallbackMessage: String {
        case newSymbol = "newSymbolCallbackHandler"
        case pullInitialData = "pullInitialDataHandler"
        case pullUpdateData = "pullUpdateDataHandler"
        case pullPaginationData = "pullPaginationDataHandler"
        case layout = "layoutHandler"
        case drawing = "drawingHandler"
        case accessibility = "accessibilityHandler"
        case log = "logHandler"
    }
    
    internal static let serverError = NSError(domain:"Server error.", code:0, userInfo:nil)
    
    internal static var carrierName: String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        return carrier?.carrierName ?? "Unknown"
    }
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    internal func initialize() {
        setupWebView()
//        NotificationCenter.default.addObserver(self, selector: #selector(ChartIQView.applicationWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ChartIQView.applicationDidBecomeActive),	 name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    /// Cleans up the message handlers in order to avoid a memory leak.
    /// Should be called when the view is about to get deallocated (e.g. the deinit of its superview)    
    public func cleanup() {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ChartIQCallbackMessage.accessibility.rawValue)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ChartIQCallbackMessage.newSymbol.rawValue)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ChartIQCallbackMessage.pullInitialData.rawValue)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ChartIQCallbackMessage.pullUpdateData.rawValue)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ChartIQCallbackMessage.pullPaginationData.rawValue)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ChartIQCallbackMessage.layout.rawValue)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: ChartIQCallbackMessage.drawing.rawValue)
    }
    
    /// Sets your webview url here.
    ///
    /// - Parameters:
    ///   - url: The starting url
    public static func start(url: String) throws {
        ChartIQView.url = url
    }
    
    // MARK: - Helper
    
    /// Sets chartIQ url
    ///
    /// - Parameter url: The chartIQ url
    public func setChartIQUrl(_ url: String) {
        ChartIQView.url = url
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
    }
    
    public func setRefreshInterval(_ refreshInterval: Int) {
        ChartIQView.refreshInterval = refreshInterval
    }
    
    public func setVoiceoverFields(_ voiceoverFields: [String: Bool]) {
        ChartIQView.voiceoverFields = voiceoverFields;
    }
    
    // MARK: - Layout
    
    /// setup WKWebView
    internal func setupWebView() {
        // Create the user content controller and add the script to it
        let userContentController = WKUserContentController()
        
        userContentController.addUserScript(layoutScript)
        userContentController.addUserScript(drawingScript)
        
        userContentController.add(self, name: ChartIQCallbackMessage.accessibility.rawValue)
        userContentController.add(self, name: ChartIQCallbackMessage.newSymbol.rawValue)
        userContentController.add(self, name: ChartIQCallbackMessage.pullInitialData.rawValue)
        userContentController.add(self, name: ChartIQCallbackMessage.pullUpdateData.rawValue)
        userContentController.add(self, name: ChartIQCallbackMessage.pullPaginationData.rawValue)
        userContentController.add(self, name: ChartIQCallbackMessage.layout.rawValue)
        userContentController.add(self, name: ChartIQCallbackMessage.drawing.rawValue)
        userContentController.add(self, name: ChartIQCallbackMessage.log.rawValue)

        // Create the configuration with the user content controller
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        // Create the web view with the configuration
        webView = WKWebView(frame: bounds, configuration: configuration)
        webView.navigationDelegate = self
        
        addSubview(webView)
        if #available(iOS 9, *) {
            setupConstraints()
        }

        if let url = URL(string: ChartIQView.chartIQUrl) {
            webView.load(URLRequest(url: url))
        }
    }
    
    /// Setup constraints
    @available(iOS 9, *)
    internal func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(
            equalTo: leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(
            equalTo: trailingAnchor).isActive = true
        webView.bottomAnchor.constraint(
            equalTo: bottomAnchor).isActive = true
        webView.topAnchor.constraint(
            equalTo: topAnchor).isActive = true
    }
    
    // MARK: - Chart Control
    
    /// Sets the data method to "push" or "pull".
    ///
    /// - Parameter method: The data method
    public func setDataMethod(_ method: ChartIQDataMethod) {
        clear()
        _dataMethod = method
        let script = "determineOs()"
        webView.evaluateJavaScript(script, completionHandler: nil)
        if method == .pull {
            print("If you want to add a quotefeed please do so in your javascript code.")
        } else {
            let script = "callNewChart(); "
            webView.evaluateJavaScript(script, completionHandler: nil)
        }
    }
    
    /// Sets the base chart type to "line", "candle", "bar", "wave", “colored_bar”, "colored_line", “hollow_candle”,"volume_candle",”scatterplot”, "baseline_delta", "baseline_delta_mountain", "mountain", "colored_mountain"
    ///
    /// - Parameter type: The chart type
    public func setChartType(_ type: ChartIQChartType) {
        var chartType = ""
        switch type {
        case .line: chartType = "line"
        case .candle: chartType = "candle"
        case .bar: chartType = "bar"
        case .wave: chartType = "wave"
        case .colored_bar: chartType = "colored_bar"
        case .colored_line: chartType = "colored_line"
        case .hollow_candle: chartType = "hollow_candle"
        case .volume_candle: chartType = "volume_candle"
        case .scatterplot: chartType = "scatterplot"
        case .baseline_delta: chartType = "baseline_delta"
        case .baseline_delta_mountain: chartType = "baseline_delta_mountain"
        case .mountain: chartType = "mountain"
        case .colored_mountain: chartType  = "colored_mountain"
        }
        let script = "setChartType(\"\(chartType)\");"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Sets the base aggregation type to "rangebars", "ohlc", "kagi", "pandf", "heikinashi", "linebreak", "renko".
    ///
    /// - Parameter type: The aggregation type
    public func setAggregationType(_ type: ChartIQAggregationType) {
        var aggregationType = ""
        switch type {
        case .rangebars: aggregationType = "rangebars"
        case .ohlc: aggregationType = "ohlc"
        case .kagi: aggregationType = "kagi"
        case .pandf: aggregationType = "pandf"
        case .heikinashi: aggregationType = "heikinashi"
        case .linebreak: aggregationType = "linebreak"
        case .renko: aggregationType = "renko"
        }
        let script = "setAggregationType(\"\(aggregationType)\");"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Sets the periodicity and interval for the chart. Interval describes the raw data interval (1, 5, 30, "day") while period describes the multiple of that interval (7 minutes, 3 days, 7 X 5 minutes). This method sets the new periodicity and creates a new dataSet.
    ///
    /// - Parameters:
    ///   - period: The number of elements from masterData to roll-up together into one data point on the chart (one candle, for example). If set to 30 in a candle chart, for example, each candle will represent 30 raw elements of interval type.
    ///   - interval: The type of data to base the period on. This can be a numeric value representing minutes, seconds or millisecond as inicated by timeUnit, "day","week", "month" or 'tick' for variable time x-axis.
    ///   - timeUnit: Optional time unit to further qualify the specified numeric interval. Valid values are "millisecond","second","minute",null. If not set, will default to "minute". only applicable and used on numeric intervals
    public func setPeriodicity(_ period: Int, interval: String, timeUnit: String = "minute") {
        var _interval = interval
        if Int(interval) == nil {
            _interval = "\"" + interval + "\""
        }
        webView.evaluateJavaScript("setPeriodicity(\(period), \(_interval), \"\(timeUnit)\");", completionHandler: nil)
    }
    
    /// Renders a chart for a particular instrument from the data passed in or fetches new data from the attached CIQ.QuoteFeed. This is the method that should be called every time a new chart needs to be drawn for a different instrument.
    ///
    /// - Parameters:
    ///   - symbol: The symbol for the new chart - a symbol string
    public func setSymbol(_ symbol: String) {
        if(UIAccessibility.isVoiceOverRunning) {
            let source = "accessibilityMode();"
            webView.evaluateJavaScript(source, completionHandler: nil)
        }
        
        let script = "callNewChart(\"\(symbol)\");"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Adds a symbol comparison to the chart.
    ///
    /// - Parameters:
    ///   - symbol: The symbol for the new chart - a symbol string
    ///   - color: Color to draw line
    public func addComparisonSymbol(_ symbol: String, color: UIColor = UIColor.red) {
        let addSeriesScript = "stxx.addSeries(\"\(symbol)\", {display:\"\(symbol)\", color: \"\(color.toHexString())\"  isComparison:true});"

        webView.evaluateJavaScript(addSeriesScript, completionHandler: nil)
    }
    
    /// Removes a symbol comparison from the chart.
    ///
    /// - Parameter symbol: The symbol for the new chart - a symbol string
    public func removeComparisonSymbol(_ symbol: String) {
        let script = "stxx.removeSeries(\"\(symbol)\");"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Sets the chart scale.
    ///
    /// - Parameter scale: The chart scale
    public func setScale(_ scale: ChartIQScale) {
        var scaleString = ""
        switch scale {
        case .log: scaleString = "log"
        case .linear: scaleString = "linear"
        }
        let script = "stxx.layout.chartScale = \"\(scaleString)\";"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Change a css style on the chart.
    ///
    /// - Parameters:
    ///   - obj: The object whose style you wish to change (stx_grid, stx_xaxis, etc)
    ///   - attribute: The style name of the object you wish to change
    ///   - value: The value to assign to the attribute
    public func changeChartStyle(_ obj: String, attribute: String, value: String) {
        let script = "stxx.setStyle(\"\(obj)\",\"\(attribute)\",\"\(value)\");"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Change a property value on the chart
    ///
    /// - Parameters:
    ///   - property: The property name of the object you wish to change
    ///   - value: The value to assign to the property
    public func setChartProperty(_ property: String, value: Any) {
        let script = "stxx.chart.\(property) = \"\(value)\";"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// get a property value on the chart
    ///
    /// - Parameters:
    ///   - property: The property name of the object you wish to receive
    public func getChartProperty(_ property: String) -> String {
        let script = "stxx.chart.\(property);"
        return webView.evaluateJavaScriptWithReturn(script)!
    }
    
    /// Change a property value on the chart engine
    ///
    /// - Parameters:
    ///   - property: The property name of the object you wish to change
    ///   - value: The value to assign to the property
    public func setEngineProperty(_ property: String, value: Any) {
        let script = "stxx.\(property) = \"\(value)\";"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    // get a property value on the chart engine
    ///
    /// - Parameters:
    ///   - property: The property name of the object you wish to receive
    public func getEngineProperty(_ property: String) -> String {
        let script = "stxx.\(property);"
        return webView.evaluateJavaScriptWithReturn(script)!
    }
    
    /// Turns crosshairs on
    public func enableCrosshairs() {
        let script = "enableCrosshairs(true);"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Turns crosshairs off
    public func disableCrosshairs() {
        let script = "enableCrosshairs(false);"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Checks if crosshairs is on
    ///
    /// - Returns: true if crosshair is on
    public func isCrosshairsEnabled() -> Bool {
        let script = "if (stxx.layout.crosshair == true) { \"true\" } else { \"false\" } "
        return webView.evaluateJavaScriptWithReturn(script) == "true"
    }
    
    /// Gets crosshair highlighted price data for HUD 
    public func getCrosshairsHUDDetail() -> CrosshairHUD? {
        let script = "getHudDetails();"
        let result = webView.evaluateJavaScriptWithReturn(script)
        if let result = result, let data = result.data(using: .utf8) {
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if let dict = json as? [String: String] {
                return CrosshairHUD(open: dict["open"] ?? "", high: dict["high"] ?? "", low: dict["low"] ?? "", close: dict["close"] ?? "", volume: dict["volume"] ?? "")
            }
        }
        return nil
    }
    
    /// Checks if chart has finished loading
    ///
    /// - Returns: true if the chart has finished loading
    public func isChartAvailable() -> Bool {
        let script = "if (isChartAvailable() == true) { \"true\" } else { \"false\" } "
        return webView.evaluateJavaScriptWithReturn(script) == "true"
    }

    /// Sets the theme for the chart
    /// 'none' is there if the user wants to use custom themes they created
    /// valid values: day, night, none
    ///
    public func setTheme(_ theme: String) {
        webView.evaluateJavaScript("setTheme(\"\(theme)\");")
    }
    
    public func resizeChart() {
        webView.evaluateJavaScript("resizeScreen();", completionHandler: nil)
    }
    
    /// Clears out a chart, eliminating all references including the resizeTimer, quoteDriver, styles and eventListeners
    public func clear() {
        let script = "stxx.destroy();"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    // MARK: - Set Chart data
    
    /// Sets the chart data by push.
    ///
    /// - Parameters:
    ///   - symbol: The symbol for the new chart
    ///   - data: An array of properly formatted OHLC quote objects to create a chart
    public func push(_ data: [ChartIQData]) {
        let obj = data.map{ $0.toDictionary() }
        let jsonData = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "") ?? ""
        let script = "callNewChart(\"\", \(jsonString)); "
        self.webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Uses this method to stream OHLC data into a chart.
    ///
    /// - Parameter data: An array of properly formatted OHLC quote objects to append
    public func pushUpdate(_ data: [ChartIQData]) {
        let obj = data.map{ $0.toDictionary() }
        let jsonData = try! JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "") ?? ""
        let script = "parseData('\(jsonString)');"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    // MARK: - Study
    
    /// Gets all of the available studies.
    fileprivate func getStudyObjects() {
        let script = "JSON.stringify(CIQ.Studies.studyLibrary);"
        webView.evaluateJavaScript(script) { [weak self](result, error) in
            guard let strongSelf = self else { return }
            strongSelf.studyObjects = [Study]()
            if let result = result as? String, let data = result.data(using: .utf8) {
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                if let dict = json as? [String: Any] {
                    for key in dict.keys {
                        if let studyDict = dict[key] as? [String: Any] {
                            var studyName = key
                            if let name = studyDict["name"] as? String, !name.isEmpty {
                                studyName = name
                            }
                            let study = Study(shortName: key, name: studyName, inputs: studyDict["inputs"] as! [String : Any]?, outputs: studyDict["outputs"] as! [String : Any]?, parameters: studyDict["parameters"] as! [String: Any]?)
                            strongSelf.studyObjects.append(study)
                        }
                    }
                    strongSelf.studyObjects.sort{ $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending  }
                }
            }
        }
    }
    
    /// Gets all of the available studies.
    public func getStudyList() -> [Study] {
        return studyObjects
    }
    
    /// Gets study input parameters.
    ///
    /// - Parameter name: The study name
    /// - Returns: The JSON Object or nil if an error occur
    public func getStudyInputParameters(by name: String) -> Any?  {
        let script = "getStudyParameters(\"" + name + "\" , \"inputs\");"
        if let jsonString = webView.evaluateJavaScriptWithReturn(script), let data = jsonString.data(using: .utf8) {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let inputs = json as? [[String: Any]] {
                return inputs.filter({ (input) -> Bool in
                    let name = input["name"] as? String
                    return name != nil && name != "id" && name != "display"
                })
            }
            return json
        }
        return nil
    }
    
    /// Gets study outputs or parameters.
    ///
    /// - Parameter name: The study name
    /// - Returns: The JSON Object or nil if an error occur
    public func getStudyOutputsOrParameters(by name: String, type: String) -> Any?  {
        let script = "getStudyParameters(\"" + name + "\" , \"" + type + "\");"
        if let jsonString = webView.evaluateJavaScriptWithReturn(script), let data = jsonString.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                return json
            } catch {
                return nil
            }
        }
        return nil
    }
    
    /// Sets study parameters.
    ///
    /// - Parameters:
    ///   - name: The study name
    ///   - key: The parameter name that must be defined in CIQ.Studies.DialogHelper
    ///   - value: The value
    public func setStudy(_ name: String, withParameter key: String, value: String) {
        let script = "setStudy(\"\(name)\", \"\(key)\", \"\(value)\")"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Sets study parameters.
    ///
    /// - Parameters:
    ///   - name: The study name
    ///   - parameter: The parameter name that must be defined in CIQ.Studies.DialogHelper
    public func setStudy(_ name: String, parameters: [String: String]) {
        var script = getStudyDescriptorScript(with: name) +
            "var helper = new CIQ.Studies.DialogHelper({sd:selectedSd,stx:stxx}); " +
            "var isFound = false; " +
            "var newInputParameters = {}; " +
            "var newOutputParameters = {}; "
    
        parameters.forEach { (parameter) in
            script += getUpdateStudyParametersScript(parameter: parameter.key, value: parameter.value)
        }
        
        script += "helper.updateStudy({inputs:newInputParameters, outputs:newOutputParameters}); "
        
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Adds study on the Chart.
    ///
    /// - Parameters:
    ///   - name: The study name
    ///   - inputs: Inputs for the study instance. If nil, it will use the paramters defined in CIQ.Studies.DialogHelper.
    ///   - outputs: Outputs for the study instance. If nil, it will use the paramters defined in CIQ.Studies.DialogHelper.
    /// - Throws: ChartIQStudyError
    public func addStudy(_ name: String, with inputs: [String: Any]? = nil, outputs: [String: Any]? = nil) throws {
        var _inputs = String("null")
        var _outputs = String("null")
        if let inputs = inputs {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: inputs, options: .prettyPrinted)
                _inputs = String(data: jsonData, encoding: .utf8)!
            } catch {
                throw ChartIQStudyError.invalidInput
            }
        }
        if let outputs = outputs {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: outputs, options: .prettyPrinted)
                _outputs = String(data: jsonData, encoding: .utf8)!
            } catch {
                throw ChartIQStudyError.invalidOutput
            }
        }
        
        if (studyObjects.filter{ $0.shortName == name }).isEmpty {
            throw ChartIQStudyError.studyNotFound
        }
        
        let script = "addStudy('\(name)', \(_inputs), \(_outputs));"
        webView.evaluateJavaScript(script, completionHandler: nil)        
    }
    
    /// Removes study from the Chart.
    ///
    /// - Parameter name: The study name
    public func removeStudy(_ name: String) {
        let script = "removeStudy('\(name)');"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Remove all studies from the Chart.
    public func removeAllStudies() {
        let script = "removeAllStudies();"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Lists studies added on the Chart.
    ///
    /// - Returns: The array of Study name
    
    // abstract and maybe refactor
    public func getAddedStudyList() -> [Study] {
        var addedStudy = [Study]()
        let script = "getAddedStudies();"
        if let listString = webView.evaluateJavaScriptWithReturn(script), !listString.isEmpty {
            let list = listString.components(separatedBy: "||")
            list.forEach({ (study) in
                let components = study.components(separatedBy: "___")
                var name = components[0]
                /// Swift seems to have trouble parsing out the zwnb from pipe used to separate our studies
                if name.contains("|\u{200c}") {
                    name.remove(at: name.startIndex)
                    name.insert("\u{200c}", at: name.startIndex)
                    }
                let inputString = components[1]
                let outputString = components[2]
                let parametersString = components[3]
                var inputs: [String: Any]?
                var outputs: [String: Any]?
                var parameters: [String: Any]?
                if !inputString.isEmpty, let data = inputString.data(using: .utf8) {
                    inputs = (try? JSONSerialization.jsonObject(with: data, options: [])) as! [String : Any]?
                }
                if !outputString.isEmpty, let data = outputString.data(using: .utf8) {
                    outputs = (try? JSONSerialization.jsonObject(with: data, options: [])) as! [String: Any]?
                }
                if !parametersString.isEmpty, let data = parametersString.data(using: .utf8) {
                    parameters = (try? JSONSerialization.jsonObject(with: data, options: [])) as! [String: Any]?
                }
                let studyObject = Study(shortName: name, name: name, inputs: inputs, outputs: outputs, parameters: parameters)
                addedStudy.append(studyObject)
            })
        }
        return addedStudy
    }
    
    // MARK: - Drawing
    
    /// Gets current draw tool
    public func getCurrentDrawTool() -> ChartIQDrawingTool? {
        let name = webView.evaluateJavaScriptWithReturn("currentDrawing")
        for index in 0 ... ChartIQDrawingTool.verticalLine.rawValue {
            if getDrawToolName(for: ChartIQDrawingTool(rawValue: index)!) == name {
                return ChartIQDrawingTool(rawValue: index)
            }
        }
        return nil
    }

    /// Gets draw tool name
    internal func getDrawToolName(for tool: ChartIQDrawingTool) -> String {
        switch tool {
        case .channel: return "channel"
        case .continuousLine: return "continuous"
        case .doodle: return "freeform"
        case .ellipse: return "ellipse"
        case .fibarc: return "fibarc"
        case .fibfan: return "fibfan"
        case .fibretrace: return "fibonacci"
        case .fibtimezone: return "fibtimezone"
        case .gartley: return "gartley"
        case .horizontalLine: return "horizontal"
        case .line: return "line"
        case .pitchfork: return "pitchfork"
        case .ray: return "ray"
        case .rectangle: return "rectangle"
        case .segment: return "segment"
        case .verticalLine: return "vertical"
        }
    }
    
    /// Check if the drawing is supporting fill
    ///
    /// - Parameter tool: The draw tool
    public func isSupportingFill(for tool: ChartIQDrawingTool) -> Bool {
        switch tool {
        case .channel, .ellipse, .fibarc, .fibfan, .fibretrace, .fibtimezone, .gartley, .rectangle, .segment: return true
        default: return false
        }
    }
    
    /// Check if the drawing is supporting pattern
    ///
    /// - Parameter tool: The draw tool
    public func isSupportingPattern(for tool: ChartIQDrawingTool) -> Bool {
        switch tool {
        case .fibarc, .fibfan, .fibretrace, .fibtimezone: return false
        default: return true
        }
    }
    
    /// Enables drawing on the chart.
    ///
    /// - Parameter type: The drawing tool
    public func enableDrawing(with tool: ChartIQDrawingTool) {
        let script =
            "currentDrawing = \"\(getDrawToolName(for: tool))\"; " +
            "stxx.changeVectorType(currentDrawing); "
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Gets the input parameters for a drawing
    public func getDrawingParameters() -> Any? {
        if getCurrentDrawTool() != nil {
        }
        let script = "JSON.stringify(stxx.currentVectorParameters);"
        if let jsonString = webView.evaluateJavaScriptWithReturn(script), let data = jsonString.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: [])
        }
        return nil
    }
    
    /// Sets drawing parameters on the chart.
    ///
    /// - Parameters:
    ///   - key: The parameter name
    ///   - value: The value
    public func setDrawing(withParameter key: String, value: Any) {
        let script =
            "stxx.currentVectorParameters.\(key) = \(value is String ? "\"\(value)\"" : value); "
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Disables drawing on the chart.
    public func disableDrawing() {
        let script = "stxx.changeVectorType(null); " +
            "currentDrawing = \"\" ; "
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Clears drawing on the chart.
    public func clearDrawing() {
        let script = "stxx.clearDrawings();"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    public func invoke(functionName: String, args: Any...) -> Any {
        let jsonData = try! JSONSerialization.data(withJSONObject: args, options: .prettyPrinted)
        let json = String(data: jsonData, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "") ?? ""
        
        let script = "stxx.\(functionName)(\(json));"
        let value = webView.evaluateJavaScriptWithReturn(script)
        var result = ""

        if value != nil {
            result = unwrapOptional(any: value as Any) as! String
        }
        return result
    }
    
    public func unwrapOptional(any:Any) -> Any {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }
        
        if mi.children.count == 0 { return NSNull() }
        let (_, some) = mi.children.first!
        return some
    }
    
    // MARK: - Private
    
    /// Uses this method to load the default ChartIQView setting
    fileprivate func loadDefaultSetting() {
        let script = "stxx.layout.chartScale = \"log\";"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Uses this method to generate the javascript of updating study parameter
    ///
    /// - Parameters:
    ///   - parameter: The study parameter name
    ///   - value: The study parameter value
    /// - Returns: The javascript of updating study descriptor
    fileprivate func getUpdateStudyParametersScript(parameter: String, value: String) -> String{
        let updateParametersScript =
            "for (x in helper.inputs) {" +
            "   var input = helper.inputs[x]; " +
            "   if (input[\"name\"] === \"\(parameter)\") { " +
            "       isFound = true; " +
            "       if (input[\"type\"] === \"text\" || input[\"type\"] === \"select\") { " +
            "           newInputParameters[\"\(parameter)\"] = \"\(value)\"; " +
            "       } else if (input[\"type\"] === \"number\") { " +
            "           newInputParameters[\"\(parameter)\"] = parseFloat(\"\(value)\"); " +
            "       } else if (input[\"type\"] === \"checkbox\") { " +
            "           newInputParameters[\"\(parameter)\"] = \(value == "false" ? false : true); " +
            "       } " +
            "   } " +
            "} " +
            "if (isFound == false) { " +
            "   for (x in helper.outputs) { " +
            "       var output = helper.outputs[x]; " +
            "       if (output[\"name\"] === \"\(parameter)\") { " +
            "           newOutputParameters[\"\(parameter)\"] = \"\(value)\"; " +
            "       } " +
            "   } " +
            "} " +
            "isFound = false;"
        return updateParametersScript
    }
    
    /// Uses this method to generate the javascript of getting study descriptor
    ///
    /// - Parameter name: The name of study descriptor
    /// - Returns: The javascript of getting study descriptor
    fileprivate func getStudyDescriptorScript(with name: String) -> String{
        let script =
            "var s=stxx.layout.studies; " +
            "var selectedSd = {}; " +
            "for(var n in s){ " +
            "   var sd=s[n]; " +
            "if (sd.name === \"\(name)\") { selectedSd = sd; }} "
        return script
    }
    
    /// Uses this method to pass the array of ChartIQData to js and ask the chart to update
    ///
    /// - Parameters:
    ///   - data: An array of properly formatted OHLC quote objects to append
    ///   - cb: The callback key used in Javascript
    fileprivate func formatJSQuoteData(from data: [ChartIQData], cb: String) {
        let data = try! JSONSerialization.data(withJSONObject: data.map{ $0.toDictionary()}, options: .prettyPrinted)
        let json = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "") ?? ""
        let script = "parseData('\(json)', \"\(cb)\");"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    /// Uses this method to format object to printed JSON format
    ///
    /// - Parameter object: The object
    /// - Returns: The JSON object
    fileprivate func formatObjectToPrintedJSONFormat(_ object: Any) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString!)
        return jsonString ?? ""
    }
    
}

// MARK: - WKScriptMessageHandler

extension ChartIQView: WKScriptMessageHandler {
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let callbackMessage = ChartIQCallbackMessage(rawValue: message.name) else { return }
        switch callbackMessage {
        case .newSymbol:
            if let symbol = message.body as? String {
                delegate?.chartIQView?(self, didUpdateSymbol: symbol)
            }
        case .pullInitialData:
            let message = message.body as! [String: Any]
            let cb = message["cb"] as? String ?? ""
            let symbol = message["symbol"] as? String ?? ""
            let startDate = message["startDate"] as? String ?? ""
            let endDate = message["endDate"] as? String ?? ""
            let interval = message["interval"] as? String ?? ""
            let period = message["period"] as? Int ?? 0
            let params = ChartIQQuoteFeedParams(symbol: symbol, startDate: startDate, endDate: endDate, interval: interval, period: period)
            dataSource?.pullInitialData(by: params, completionHandler: {[weak self] (data) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.formatJSQuoteData(from: data, cb: cb)
                }
            })
        case .pullUpdateData:
            let message = message.body as! [String: Any]
            let cb = message["cb"] as? String ?? ""
            let symbol = message["symbol"] as? String ?? ""
            let startDate = message["startDate"] as? String ?? ""
            let endDate = message["endDate"] as? String ?? ""
            let interval = message["interval"] as? String ?? ""
            let period = message["period"] as? Int ?? 0
            let params = ChartIQQuoteFeedParams(symbol: symbol, startDate: startDate, endDate: endDate, interval: interval, period: period)
            dataSource?.pullUpdateData(by: params, completionHandler: {[weak self] (data) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.formatJSQuoteData(from: data, cb: cb)
                }
            })
        case .pullPaginationData:
            let message = message.body as! [String: Any]
            let cb = message["cb"] as? String ?? ""
            let symbol = message["symbol"] as? String ?? ""
            let startDate = message["startDate"] as? String ?? ""
            let endDate = message["endDate"] as? String ?? ""
            let interval = message["interval"] as? String ?? ""
            let period = message["period"] as? Int ?? 0
            let params = ChartIQQuoteFeedParams(symbol: symbol, startDate: startDate, endDate: endDate, interval: interval, period: period)
            dataSource?.pullPaginationData(by: params, completionHandler: {[weak self] (data) in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    strongSelf.formatJSQuoteData(from: data, cb: cb)
                }
            })
        case .layout:
            if let message = message.body as? String, let data = message.data(using: .utf8) {
                do {
                    let layout = try JSONSerialization.jsonObject(with: data, options: [])
                    delegate?.chartIQView?(self, didUpdateLayout: layout)
                } catch {
                    print("No Layout return")
                }
            }
        case .drawing:
            if let message = message.body as? String, let data = message.data(using: .utf8) {
                do {
                    let drawings = try JSONSerialization.jsonObject(with: data, options: [])
                    delegate?.chartIQView?(self, didUpdateDrawing: drawings)
                } catch {
                    print("Drawing callback fail")
                }
            }
        case .accessibility:
            if let quote = message.body as? String {
                let fieldsArray = quote.components(separatedBy: "||")

                if fieldsArray.count == 6 {
                    let date = fieldsArray[0]
                    let close = fieldsArray[1]
                    let open = fieldsArray[2]
                    let high = fieldsArray[3]
                    let low = fieldsArray[4]
                    let volume = fieldsArray[5]
                    
                    // the below is very clunky, find a better way in the future
                    // maybe first idea of passing in fields to library instead 
                    // of getting everything back
                    var selectedFields = ""
                    
                    if ChartIQView.voiceoverFields[ChartIQQuoteFields.date.rawValue]! {
                        selectedFields += ", " + date
                    }
                    
                    if ChartIQView.voiceoverFields[ChartIQQuoteFields.close.rawValue]! {
                        selectedFields += ", " + close
                    }
                    
                    if ChartIQView.voiceoverFields[ChartIQQuoteFields.open.rawValue]! {
                        selectedFields += ", " + open
                    }
                    
                    if ChartIQView.voiceoverFields[ChartIQQuoteFields.high.rawValue]! {
                        selectedFields += ", " + high
                    }
                    
                    if ChartIQView.voiceoverFields[ChartIQQuoteFields.low.rawValue]! {
                        selectedFields += ", " + low
                    }
                    
                    if ChartIQView.voiceoverFields[ChartIQQuoteFields.volume.rawValue]! {
                        selectedFields += ", " + volume
                    }
                    
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: selectedFields);
                } else {
                    // field is missing, just quote the entire value
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: quote);
                }
            }
        case .log:
        // Allows for various console messages from JavaScript to show up in Xcode console.
        // Accepted console methods are "log," "warning," and "error".
            let message = message.body as! [String: Any]
            let method = message["method"] as? String ?? "LOG"
            let arguments = message["arguments"] as! [String: String]
            var msg: String = ""
            for (_, value) in arguments {
                if (msg.count > 0) {
                    msg += "\n"
                }

                msg += value
            }
            NSLog("%@: %@", method, msg)
        }
    }
}

extension ChartIQView : WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getStudyObjects()
        loadDefaultSetting()
        delegate?.chartIQViewDidFinishLoading(self)
    }

}
