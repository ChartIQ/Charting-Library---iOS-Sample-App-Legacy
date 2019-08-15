//
//  ViewController.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 10/1/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit
import ChartIQ

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var chartIQView: ChartIQView!
    @IBOutlet weak var periodMenuView: UIView!
    @IBOutlet weak var periodTableView: UITableView!
    @IBOutlet weak var crosshairHUDView: UIView!
    @IBOutlet weak var crosshairHUDHighLabel: UILabel!
    @IBOutlet weak var crosshairHUDLowLabel: UILabel!
    @IBOutlet weak var crosshairHUDCloseLabel: UILabel!
    @IBOutlet weak var crosshairHUDVolumeLabel: UILabel!
    @IBOutlet weak var drawToolView: UIView!
    @IBOutlet weak var drawToolViewHeight: NSLayoutConstraint!
    @IBOutlet weak var drawToolButton: UIButton!
    @IBOutlet weak var fillButton: UIButton!
    @IBOutlet weak var fillLabel: UILabel!
    @IBOutlet weak var lineColorButton: UIButton!
    @IBOutlet weak var lineColorLabel: UILabel!
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerViewCenterWithFill: NSLayoutConstraint!
    @IBOutlet weak var colorPickerViewCenterWithLine: NSLayoutConstraint!
    @IBOutlet weak var colorPickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var linePickerView: UIView!
    @IBOutlet weak var lineTableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @objc let defaultSymbol = "AAPL"
    @objc let defaultPeriod = 1
    @objc let defaultInterval = "day"
    @objc let refreshInterval = 1
    @objc var colors = UIColor.colorsForColorPicker()
    @objc var fillColors = UIColor.colorsForFillColorPicker()
    @objc var periodButton: UIButton!
    @objc var selectedIntervalIndexPath = IndexPath(row: 0, section: 2)
    @objc var selectedDrawTool: String?
    
    enum SegueIdentifier: String {
        case searchStudiesSegue = "SearchStudiesSegue"
        case drawOptionsSegue = "DrawOptionsSegue"
        case settingsSegue = "SettingsSegue"
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupNavigationBar()
        setupChartIQView()
        setupPeriodMenuView()
        
        UserDefaults.standard.set(ChartIQView.chartIQUrl, forKey: "ChartIQURL")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier.flatMap(SegueIdentifier.init) else { return }
        
        switch identifier {
        case .settingsSegue:
            let viewController = segue.destination as! SettingViewController
            setupSettingsController(viewController)
            
        case .drawOptionsSegue:
            let viewController = segue.destination as! OptionsViewController
            setupDrawingController(viewController)
            
        case .searchStudiesSegue:
            let viewController = segue.destination as! SearchStudiesViewController
            setupSearchStudiesController(viewController)
        }
    }

    // MARK: - Layout
    
    @objc func setupNavigationBar() {
        periodButton = UIButton(type: .custom)
        periodButton.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        periodButton.backgroundColor = UIColor.clear
        periodButton.setBackgroundImage(#imageLiteral(resourceName: "ButtonBorder"), for: .normal)
        periodButton.setTitle("1 DAY", for: .normal)
        periodButton.titleLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 11)
        periodButton.addTarget(self, action: #selector(ViewController.periodBarButtonDidClick), for: .touchUpInside)
        let periodBarButton = UIBarButtonItem(customView: periodButton)
        let crosshairBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Crosshair"), style: .plain, target: self, action: #selector(ViewController.crosshairBarButtonDidClick))
        crosshairBarButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItems = [crosshairBarButton, periodBarButton]
        let logoImageview = UIImageView(image: #imageLiteral(resourceName: "Logo"))
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -6
        
        navigationItem.leftBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: logoImageview)]
    }
    
    @objc func setupChartIQView() {
        chartIQView.dataSource = self
        chartIQView.delegate = self
    }
    
    @objc func setupPeriodMenuView() {
        navigationController!.view.addSubview(periodMenuView)
        periodMenuView.translatesAutoresizingMaskIntoConstraints = false
        periodMenuView.leadingAnchor.constraint(
            equalTo: navigationController!.view.leadingAnchor).isActive = true
        periodMenuView.trailingAnchor.constraint(
            equalTo: navigationController!.view.trailingAnchor).isActive = true
        periodMenuView.bottomAnchor.constraint(
            equalTo: navigationController!.view.bottomAnchor).isActive = true
        periodMenuView.topAnchor.constraint(
            equalTo: navigationController!.view.topAnchor).isActive = true
        periodTableView.reloadData()
    }
    
    @objc func updateCrosshairHUDView(with hud: CrosshairHUD) {
        crosshairHUDLowLabel.text = hud.low
        crosshairHUDHighLabel.text = hud.high
        crosshairHUDCloseLabel.text = hud.close
        crosshairHUDVolumeLabel.text = hud.volume
    }
    
    @objc func showCrosshairsHUD() {
        if chartIQView.isCrosshairsEnabled() {
            if let hud = chartIQView.getCrosshairsHUDDetail() {
                updateCrosshairHUDView(with: hud)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.showCrosshairsHUD()
            })
        }
    }
    
    @objc func showDrawToolView() {
        drawToolButton.setTitle(selectedDrawTool, for: .normal)
        drawToolViewHeight.constant = 60
        drawToolView.isHidden = false
        fillLabel.isHidden = true
        fillButton.isHidden = true
        lineColorLabel.isHidden = true
        lineColorButton.isHidden = true
        lineButton.isHidden = true
        if let tool = chartIQView.getCurrentDrawTool(), let parameter = chartIQView.getDrawingParameters() as? [String: Any] {
            if chartIQView.isSupportingFill(for: tool), let fillColor = parameter["fillColor"] as? String {
                fillButton.isHidden = false
                fillLabel.isHidden = false
                if fillColor.hasPrefix("#") {
                    fillButton.backgroundColor = UIColor(hexString: fillColor.replacingOccurrences(of: "#", with: ""))
                }
            }
            if let lineColor = parameter["currentColor"] as? String {
                lineColorButton.isHidden = false
                lineColorLabel.isHidden = false
                if lineColor.hasPrefix("#") {
                    lineColorButton.backgroundColor = UIColor(hexString: lineColor.replacingOccurrences(of: "#", with: ""))
                }
            }
            if chartIQView.isSupportingPattern(for: tool), let pattern = parameter["pattern"] as? String, let lineWidth = parameter["lineWidth"] as? Int {
                lineButton.isHidden = false
                lineButton.setImage(Line.line(from: pattern)?.buttonimage(for: lineWidth), for: .normal)
            }
        }
    }
    
    @objc func hideDrawToolView() {
        drawToolViewHeight.constant = 0
        drawToolView.isHidden = true
    }
    
    // MARK: - Helper
    
    @objc func pushCurrentUpdate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'10:00:00.000'Z'"
        let date = dateFormatter.string(from: Date())
        let symbol = chartIQView.symbol
        let chartInterval = chartIQView.interval
        let chartPeriod = chartIQView.periodicity
        let isMinute = Int(chartInterval) != nil
        let _interval = isMinute ? "minute" : chartInterval
        let _period = isMinute ? Int(chartIQView.interval)! : chartIQView.periodicity
        let params = ChartIQQuoteFeedParams(symbol: symbol, startDate: date, endDate: "", interval: _interval, period: _period)
        loadChartData(by: params, completionHandler: {[weak self] (data) in
            guard let strongSelf = self else { return }
            if strongSelf.chartIQView.interval == chartInterval && strongSelf.chartIQView.periodicity == chartPeriod && strongSelf.chartIQView.symbol == symbol {
                strongSelf.chartIQView.pushUpdate(data)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                strongSelf.pushCurrentUpdate()
            })
        })
    }
    
    @objc func setupSettingsController(_ viewController: SettingViewController) {
        viewController.currentScale = chartIQView.scale
        viewController.currentChartType = chartIQView.chartType
        viewController.currentAggregationType = chartIQView.aggregationType
        
        // Sets chart style
        viewController.styleDidChangeBlock = {[weak self] (style) in
            guard let strongSelf = self else { return }
            strongSelf.chartIQView.setChartType(style)
        }
        
        // Sets chart aggregation type
        viewController.aggregationTypeDidChangeBlock = {[weak self] (type) in
            guard let strongSelf = self else { return }
            strongSelf.chartIQView.setAggregationType(type)
        }
        
        // Sets chart scale
        viewController.scaleDidChangeBlock = {[weak self] (scale) in
            guard let strongSelf = self else { return }
            strongSelf.chartIQView.setScale(scale)
        }
        
        // Sets chartIQ url
        viewController.urlDidChangeBlock = {[weak self] (url) in
            guard let strongSelf = self else { return }
            strongSelf.chartIQView.setChartIQUrl(url)
        }
    }
    
    @objc func setupDrawingController(_ viewController: OptionsViewController) {
        viewController.title = "Select a drawing tool"
        viewController.rightButtonTitle = "Clear All Drawings"
        viewController.isRightButtonHidden = false
        
        // Sets all drawing tools
        for index in 0 ... ChartIQDrawingTool.verticalLine.rawValue {
            let name = getDrawingToolDisplayName(for: ChartIQDrawingTool(rawValue: index)!)
            viewController.options.append(name)
        }
        
        // Sets current drawing tool
        if let currentDrawingTool = chartIQView.getCurrentDrawTool() {
            viewController.selectedOption = getDrawingToolDisplayName(for: currentDrawingTool)
        }
        
        // Clears all drawing
        viewController.rightButtonDidClickBlock = {[weak self] (_) in
            guard let strongSelf = self else { return }
            let alertController = UIAlertController(title: "You are about to clear all of your drawings on this chart, are you sure?", message: "", preferredStyle: .actionSheet)
            let firstAction = UIAlertAction(title: "Clear all drawings", style: .default) { (alert: UIAlertAction!) -> Void in
                strongSelf.chartIQView.disableDrawing()
                strongSelf.chartIQView.clearDrawing()
                strongSelf.hideDrawToolView()
                alertController.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert: UIAlertAction!) -> Void in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(firstAction)
            alertController.addAction(cancelAction)
            strongSelf.present(alertController, animated: true, completion:nil)
        }
        
        // Enables Drawing
        viewController.optionsDidChangeBlock = {[weak self] (name) in
            guard let strongSelf = self else { return }
            
            strongSelf.selectedDrawTool = name
            for index in 0 ... ChartIQDrawingTool.verticalLine.rawValue {
                if name == strongSelf.getDrawingToolDisplayName(for: ChartIQDrawingTool(rawValue: index)!) {
                    strongSelf.chartIQView.enableDrawing(with: ChartIQDrawingTool(rawValue: index)!)
                    strongSelf.showDrawToolView()
                    break
                }
            }
        }
    }
    
    @objc func setupSearchStudiesController(_ viewController: SearchStudiesViewController) {
        viewController.allStudies = chartIQView.getStudyList()
        
        // Adds studies
        viewController.addStudiesBlock = {[weak self] (studies) in
            guard let strongSelf = self else { return }
            studies.forEach({ (study) in
                try! strongSelf.chartIQView.addStudy(study.shortName)
            })
            viewController.addedStudies = strongSelf.chartIQView.getAddedStudyList()
        }
        
        // Removes studies
        viewController.removeStudiesBlock = {[weak self] (studies) in
            guard let strongSelf = self else { return }
            studies.forEach({ (study) in
                strongSelf.chartIQView.removeStudy(study.name)
            })
            viewController.addedStudies = strongSelf.chartIQView.getAddedStudyList()
        }
        
        // Gets study parameter
        viewController.getStudyParameterBlock = {[weak self] (study) -> (Any?, Any?, Any?) in
            guard let strongSelf = self else { return (nil, nil, nil)}
            let input = strongSelf.chartIQView.getStudyInputParameters(by: study)
            let output = strongSelf.chartIQView.getStudyOutputsOrParameters(by: study, type: "outputs")
            let parameters = strongSelf.chartIQView.getStudyOutputsOrParameters(by: study, type: "parameters")
            return (input, output, parameters)
        }
        
        // Edits study parameter
        viewController.editStudiesBlock = {[weak self] (study) in
            guard let strongSelf = self else { return }
            var parameters = [String: String]()
            study.inputs?.forEach({ (input) in
                parameters[input.key] = String(describing: input.value)
            })
            study.outputs?.forEach({ (output) in
                parameters[output.key] = String(describing: output.value)
            })
            study.parameters?.forEach({ (param) in
                parameters[param.key] = String(describing: param.value)
            })
            strongSelf.chartIQView.setStudy(study.name, parameters: parameters)
        }
        
        // Gets added studies
        viewController.getAddedStudiesBlock = {[weak self] () -> [Study] in
            guard let strongSelf = self else { return [Study]() }
            return strongSelf.chartIQView.getAddedStudyList()
        }
    }

    @objc func loadChartInitialData(symbol: String, period: Int, interval: String, completionHandler: @escaping ([ChartIQData]) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        let endDate = dateFormatter.string(from: Date())
        let isMinute = Int(interval) != nil
        let _interval = isMinute ? "minute" : interval
        let _period = isMinute ? Int(interval)! : period
        let params = ChartIQQuoteFeedParams(symbol: symbol, startDate: "2016-12-16T16:00:00.000Z", endDate: endDate, interval: _interval, period: _period)
        loadChartData(by: params, completionHandler: {[weak self] (data) in
            guard self != nil else { return }
            completionHandler(data)
        })
    }
    
    @objc func getDrawingToolDisplayName(for tool: ChartIQDrawingTool) -> String {
        switch tool {
        case .channel: return "Channel"
        case .continuousLine: return "Continuous Line"
        case .doodle: return "Doodle"
        case .ellipse: return "Ellipse"
        case .fibarc: return "Fibarc"
        case .fibfan: return "Fibfan"
        case .fibretrace: return "Fibonacci"
        case .fibtimezone: return "Fibtimezone"
        case .gartley: return "Gartley"
        case .horizontalLine: return "Horizontal Line"
        case .line: return "Line"
        case .pitchfork: return "Pitchfork"
        case .ray: return "Ray"
        case .rectangle: return "Rectangle"
        case .segment: return "Segment"
        case .verticalLine: return "Vertical Line"
        }
    }
    
    @objc func showPeriodMenu() {
        UIView.animate(withDuration: 0.3) { self.periodMenuView.alpha = 1 }
    }
    
    @objc func hidePeriodMenu() {
        UIView.animate(withDuration: 0.3) { self.periodMenuView.alpha = 0 }
    }
    
    // MARK: - Data
    
    @objc let uuid = UUID().uuidString;
    
    @objc func loadChartData(by params: ChartIQQuoteFeedParams, completionHandler: @escaping ([ChartIQData]) -> Void) {
        let urlString =
            "http://simulator.chartiq.com/datafeed?identifier=\(params.symbol)" +
                "&startdate=\(params.startDate)" +
                "\(params.endDate.isEmpty ? "" : "&enddate=\(params.endDate)")" +
                "&interval=\(params.interval)" +
                "&period=\(params.period)" +
                "&extended=1" +
        		"&session=\(uuid)"
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let strongSelf = self else { return }
            guard error == nil else { return }
            guard let data = data else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
            var chartData = [ChartIQData]();
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let result = json as? [[String: Any]] else { return }
                
                result.forEach({ (item) in
                    let close = item["Close"] as? Double ?? 0
                    let dt = item["DT"] as? String ?? ""
                    let date = dateFormatter.date(from: dt)!
                    let high = item["High"] as? Double ?? 0
                    let low = item["Low"] as? Double ?? 0
                    let open = item["Open"] as? Double ?? 0
                    let volume = item["Volume"] as? Int ?? 0
                    let _data = ChartIQData(date: date, open: open, high: high, low: low, close: close, volume: Double(volume), adj_close: close)
                    chartData.append(_data)
                })
                completionHandler(chartData)
            } catch {
                let alertController = UIAlertController(title: "", message: "Invalid symbol", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (alert: UIAlertAction!) -> Void in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(cancelAction)
                strongSelf.present(alertController, animated: true, completion:nil)
                completionHandler([ChartIQData]())
            }
        }
        task.resume()
    }
    
    // MARK: - Action
    
    @IBAction func symbolTextFieldDidChange(_ sender: UITextField) {
        sender.clearButtonMode = sender.text!.isEmpty ? .never : .always
    }
    
    @IBAction func crosshairBarButtonDidClick() {
        searchTextField.resignFirstResponder()
        colorPickerView.isHidden = true
        linePickerView.isHidden = true
        if chartIQView.isCrosshairsEnabled() {
            chartIQView.disableCrosshairs()
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "Crosshair")
            crosshairHUDView.isHidden = true
        } else {
            chartIQView.enableCrosshairs()
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "Crosshair_selected")
            crosshairHUDView.isHidden = false
            showCrosshairsHUD()
        }
    }
    
    @IBAction func periodBarButtonDidClick() {
        searchTextField.resignFirstResponder()
        colorPickerView.isHidden = true
        linePickerView.isHidden = true
        showPeriodMenu()
    }
    
    @IBAction func periodMenuViewDidTap() {
        hidePeriodMenu()
    }
    
    @IBAction func drawButtonDidClick(_ sender: UIButton) {
        if !drawToolView.isHidden && sender != drawToolButton {
            hideDrawToolView()
            colorPickerView.isHidden = true
            linePickerView.isHidden = true
            chartIQView.disableDrawing()
        } else {
            performSegue(withIdentifier: SegueIdentifier.drawOptionsSegue.rawValue, sender: nil)
        }
    }
    
    @IBAction func fillButtonDidClick(_ sender: UIButton) {
        hidePeriodMenu()
        linePickerView.isHidden = true
        colorPickerView.isHidden = !colorPickerView.isHidden && colorPickerViewCenterWithFill.isActive
        colorPickerViewHeight.constant = 299
        if !colorPickerView.isHidden {
            colorPickerViewCenterWithFill.isActive = true
            colorPickerViewCenterWithLine.isActive = false
        }
        colorCollectionView.reloadData()
    }
    
    @IBAction func lineColorButtonDidClick(_ sender: UIButton) {
        hidePeriodMenu()
        linePickerView.isHidden = true
        colorPickerView.isHidden = !colorPickerView.isHidden && colorPickerViewCenterWithLine.isActive
        colorPickerViewHeight.constant = 270
        if !colorPickerView.isHidden {
            colorPickerViewCenterWithFill.isActive = false
            colorPickerViewCenterWithLine.isActive = true
        }
        colorCollectionView.reloadData()
    }
    
    @IBAction func lineButtonDidClick(_ sender: UIButton) {
        colorPickerView.isHidden = true
        linePickerView.isHidden = !linePickerView.isHidden
        lineTableView.reloadData()
    }
    
    @IBAction func dismissButtonDidClick(_ sender: UIButton) {
        dismissButton.isHidden = true
        searchTextField.resignFirstResponder()
    }
    
}

// MARK: - ChartIQDataSource

// add comments for future developers
extension ViewController: ChartIQDataSource {
    
    public func pullInitialData(by params: ChartIQQuoteFeedParams, completionHandler: @escaping ([ChartIQData]) -> Void) {
        loadChartData(by: params, completionHandler: completionHandler)
    }
    
    public func pullUpdateData(by params: ChartIQQuoteFeedParams, completionHandler: @escaping ([ChartIQData]) -> Void) {
        loadChartData(by: params, completionHandler: completionHandler)
    }
    
    public func pullPaginationData(by params: ChartIQQuoteFeedParams, completionHandler: @escaping ([ChartIQData]) -> Void) {
        loadChartData(by: params, completionHandler: completionHandler)
    }
}

// MARK: - ChartIQDelegate

extension ViewController: ChartIQDelegate {

    func chartIQViewDidFinishLoading(_ chartIQView: ChartIQView) {
        func loadDefaultSymbol() {
            chartIQView.setRefreshInterval(refreshInterval)
            chartIQView.setSymbol(defaultSymbol)
            chartIQView.setDataMethod(.pull)
        }
        
        func loadVoiceoverFields() {
            // set field to true if voiceover mode needs to announce the value
            let voiceoverFields: [String: Bool] = [ChartIQView.ChartIQQuoteFields.date.rawValue: true,
                                                   ChartIQView.ChartIQQuoteFields.close.rawValue: true,
                                                   ChartIQView.ChartIQQuoteFields.open.rawValue: false,
                                                   ChartIQView.ChartIQQuoteFields.high.rawValue: false,
                                                   ChartIQView.ChartIQQuoteFields.low.rawValue: false,
                                                   ChartIQView.ChartIQQuoteFields.volume.rawValue: false]
            
            chartIQView.setVoiceoverFields(voiceoverFields);
        }
        
        
        loadDefaultSymbol()
        loadVoiceoverFields()
    }
    
    func chartIQView(_ chartIQView: ChartIQView, didUpdateLayout layout: Any) {
    }
    
    func chartIQView(_ chartIQView: ChartIQView, didUpdateSymbol symbol: String) {
    }
    
    func chartIQView(_ chartIQView: ChartIQView, didUpdateDrawing drawings: Any) {
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        dismissButton.isHidden = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let symbol = textField.text?.uppercased(), !symbol.isEmpty {
            textField.text = symbol
            switch chartIQView.dataMethod {
            case .push:
                loadChartInitialData(symbol: symbol, period: chartIQView.periodicity, interval: chartIQView.interval){[weak self] (data) in
                    guard let strongSelf = self else { return }
                    strongSelf.chartIQView.setSymbol(symbol)
                    strongSelf.chartIQView.push(data)
                }
            case .pull:
                chartIQView.setSymbol(symbol)
            }
            textField.resignFirstResponder()
        }
        return true
    }
    
}

// MARK: - UITableViewDataSource

extension ViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == lineTableView ? Line.dashed.rawValue + 1 : Intervals.month.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == lineTableView ? Line(rawValue: section)!.count : Intervals(rawValue: section)!.intervalCount
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView == lineTableView ? Line(rawValue: section)!.headerHeight : 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tableView == lineTableView ? UIColor.clear : UIColor.lightGray
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == lineTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineTableCell", for: indexPath) as! TableViewCell
            cell.imageViews?[0].image = Line(rawValue: indexPath.section)!.image(for: indexPath.row)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IntervalsTableCell", for: indexPath) as! TableViewCell
            var name = ""
            switch Intervals(rawValue: indexPath.section)! {
            case .minute: name = Intervals.Minute(rawValue: indexPath.row)!.displayName
            case .hour: name = Intervals.Hour(rawValue: indexPath.row)!.displayName
            case .day: name =  Intervals.Day(rawValue: indexPath.row)!.displayName
            case .week: name =  Intervals.Week(rawValue: indexPath.row)!.displayName
            case .month: name =  Intervals.Month(rawValue: indexPath.row)!.displayName
            }
            cell.labels![0].text = name
            cell.labels![0].textColor = selectedIntervalIndexPath == indexPath ? UIColor(hex: 0x4982f6) : UIColor.black
            cell.accessoryType = selectedIntervalIndexPath == indexPath ? .checkmark : .none
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == lineTableView {
            linePickerView.isHidden = true
            let line = Line(rawValue: indexPath.section)!
            chartIQView.setDrawing(withParameter: "pattern", value: line.pattern)
            chartIQView.setDrawing(withParameter: "lineWidth", value: indexPath.row + 1)
            lineButton.setImage(line.buttonimage(for: indexPath.row), for: .normal)
        } else {
            selectedIntervalIndexPath = indexPath
            let intervals = Intervals(rawValue: indexPath.section)!
            let periodInfo = intervals.period(rawValue: indexPath.row)
            let shortName = intervals.shortName(rawValue: indexPath.row)
            switch chartIQView.dataMethod {
            case .push:
                loadChartInitialData(symbol: chartIQView.symbol, period: periodInfo.0, interval: periodInfo.1) {[weak self] (data) in
                    guard let strongSelf = self else { return }
                    strongSelf.chartIQView.setPeriodicity(periodInfo.0, interval: periodInfo.1)
                    strongSelf.chartIQView.push(data)
                }
            case .pull:
                chartIQView.setPeriodicity(periodInfo.0, interval: periodInfo.1)
            }
            tableView.reloadData()
            periodButton.setTitle(shortName, for: .normal)
            periodMenuViewDidTap()
        }
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorPickerViewCenterWithFill.isActive ? fillColors.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionCell", for: indexPath)
        cell.backgroundColor = colorPickerViewCenterWithFill.isActive ? fillColors[indexPath.row] : colors[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if colorPickerViewCenterWithFill.isActive {
            fillButton.backgroundColor = colors[indexPath.row]
            chartIQView.setDrawing(withParameter: "fillColor", value: colors[indexPath.row].toHexString())
        } else {
            lineColorButton.backgroundColor = colors[indexPath.row]
            chartIQView.setDrawing(withParameter: "currentColor", value: colors[indexPath.row].toHexString())
        }
        colorPickerView.isHidden = true
    }
}
