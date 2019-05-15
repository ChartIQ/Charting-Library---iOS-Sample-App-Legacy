//
//  SettingViewController.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 1/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit
import ChartIQ

class SettingViewController: UITableViewController {
    
    // MARK: - Properties
    var currentChartType: ChartIQChartType? {
        didSet { selectedChartType = currentChartType != nil ? Style.style(from: currentChartType!) : nil }
    }
    var currentAggregationType: ChartIQAggregationType? {
        didSet { selectedAggregationType = currentAggregationType != nil ? AggregationType.type(from: currentAggregationType!) : nil }
    }
    var currentScale = ChartIQScale.log {
        didSet { selectedScale = currentScale }
    }
    var selectOptionName: String {
        if selectedAggregationType != nil {
            return selectedAggregationType?.displayName ?? ""
        } else {
            return selectedChartType?.displayName ?? ""
        }
    }
    fileprivate var selectedChartType: Style?
    fileprivate var selectedAggregationType: AggregationType?
    fileprivate var selectedScale = ChartIQScale.log
    fileprivate var newUrl: String = UserDefaults.standard.value(forKey: "ChartIQURL") as! String!
    var styleDidChangeBlock: ((ChartIQChartType) -> Void)?
    var aggregationTypeDidChangeBlock: ((ChartIQAggregationType) -> Void)?
    var scaleDidChangeBlock: ((ChartIQScale) -> Void)?
    var urlDidChangeBlock: ((String) -> Void)?
    
    enum SegueIdentifier: String {
        case optionsSegue = "OptionsSegue"
    }
    
    enum Settings: Int {
        case style
        case scale
        case url
        
        var displayName: String {
            switch self {
            case .style: return "Chart style"
            case .scale: return "Log scale"
            case .url: return "URL"
            }
        }
        
        var cellIdentifier: String {
            switch self {
            case .style: return "OptionsListTableCell"
            case .scale: return "OptionsSwitchTableCell"
            case .url: return "OptionsValueTableCell"
            }
        }
    }
    
    enum Style: Int {
        case bar
        case candle
        case wave
        case colored_bar
        case colored_line
        case hollow_candle
        case line
        case mountain
        case volume_candle
        case scatterplot
        case baselineDelta
        case baselineDeltaMountain
        case coloredMountain
        
        var displayName: String {
            switch self {
            case .bar: return "Bar"
            case .candle: return "Candle"
            case .wave: return "Wave"
            case .colored_bar: return "Colored bar"
            case .colored_line: return "Colored line"
            case .hollow_candle: return "Hollow candle"
            case .line: return "Line"
            case .mountain: return "Mountain"
            case .volume_candle: return "Volume candle"
            case .scatterplot: return "Scatter Plot"
            case .baselineDelta: return "Baseline delta"
            case .baselineDeltaMountain: return "Baseline delta mountain"
            case .coloredMountain: return "Colored mountain"
                
            }
        }
        
        var chartType: ChartIQChartType {
            switch self {
            case .bar: return .bar
            case .candle: return .candle
            case .wave: return .wave
            case .colored_bar: return .colored_bar
            case .colored_line: return .colored_line
            case .hollow_candle: return .hollow_candle
            case .line: return .line
            case .mountain: return .mountain
            case .volume_candle: return .volume_candle
            case .scatterplot: return .scatterplot
            case .baselineDelta: return .baseline_delta
            case .baselineDeltaMountain: return .baseline_delta_mountain
            case .coloredMountain: return .colored_mountain
            }
        }
        
        static func style(from type: ChartIQChartType) -> Style? {
            for index in 0 ... Style.coloredMountain.rawValue {
                if Style(rawValue: index)!.chartType == type {
                    return Style(rawValue: index)!
                }
            }
            return nil
        }
    }
    
    enum AggregationType: Int {
        case heikinAshi
        case kagi
        case linebreak
        case renko
        case rangebars
        case point_figure
        
        var displayName: String {
            switch self {
            case .heikinAshi: return "Heikin-Ashi"
            case .kagi: return "Kagi"
            case .linebreak: return "Line break"
            case .renko: return "Renko"
            case .rangebars: return "Range bars"
            case .point_figure: return "Point & figure"
            }
        }
        
        var aggregationType: ChartIQAggregationType {
            switch self {
            case .heikinAshi: return .heikinashi
            case .kagi: return .kagi
            case .linebreak: return .linebreak
            case .renko: return .renko
            case .rangebars: return .rangebars
            case .point_figure: return .pandf
            }
        }
        
        static func type(from type: ChartIQAggregationType) -> AggregationType? {
            for index in 0 ... AggregationType.point_figure.rawValue {
                if AggregationType(rawValue: index)!.aggregationType == type {
                    return AggregationType(rawValue: index)!
                }
            }
            return nil
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier.flatMap(SegueIdentifier.init) else { return }
        
        switch identifier {
        case .optionsSegue:
            let viewController = segue.destination as? OptionsViewController
            viewController?.title = "Chart Styles"
            for index in 0 ... Style.coloredMountain.rawValue {
                viewController?.options.append(Style(rawValue: index)!.displayName)
            }
            for index in 0 ... AggregationType.point_figure.rawValue {
                viewController?.options.append(AggregationType(rawValue: index)!.displayName)
            }
            viewController?.selectedOption = selectOptionName
            viewController?.optionsDidChangeBlock = {[weak self] (option)  in
                guard let strongSelf = self else { return }
                var isFound = false
                for index in 0 ... Style.coloredMountain.rawValue {
                    if option == Style(rawValue: index)!.displayName {
                        strongSelf.selectedChartType = Style(rawValue: index)!
                        strongSelf.selectedAggregationType = nil
                        isFound = true
                        break
                    }
                }
                if !isFound {
                    for index in 0 ... AggregationType.point_figure.rawValue {
                        if option == AggregationType(rawValue: index)!.displayName {
                            strongSelf.selectedAggregationType = AggregationType(rawValue: index)!
                            strongSelf.selectedChartType = nil
                            break
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Action
    
    @IBAction func applyButtonDidClick(_ sender: UIButton) {
        view.endEditing(true)
        if selectedAggregationType != nil {
            aggregationTypeDidChangeBlock?(selectedAggregationType!.aggregationType)            
        } else {
            styleDidChangeBlock?(selectedChartType!.chartType)
        }
        scaleDidChangeBlock?(selectedScale)
        if newUrl != UserDefaults.standard.value(forKey: "ChartIQURL") as! String! {
            UserDefaults.standard.set(newUrl, forKey: "ChartIQURL")
            urlDidChangeBlock?(newUrl)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonDidClick(_ sender: UIButton) {
        view.endEditing(true)
        selectedChartType = currentChartType != nil ? Style.style(from: currentChartType!) : nil
        selectedAggregationType = currentAggregationType != nil ? AggregationType.type(from: currentAggregationType!) : nil
        selectedScale = currentScale
        tableView.reloadData()
    }
    
    @IBAction func showSetUserPromptUp() {
        let alert = UIAlertController(title: "Enter username or email", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "SetUser", style: .default, handler: { [weak alert] (_) in
            let user = alert!.textFields![0].text ?? ""
            UserDefaults.standard.set(user, forKey: "SetUser")
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Settings.url.rawValue + 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsTableHeader") as! TableViewCell
        cell.labels?[0].text = "CHART CONFIG"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = Settings(rawValue: indexPath.row)!
        let cell = tableView.dequeueReusableCell(withIdentifier: setting.cellIdentifier, for: indexPath) as! TableViewCell
        cell.labels?[0].text = setting.displayName
        switch setting {
        case .style:
            cell.labels?[1].text = selectOptionName
        case .scale:
            cell.switchs?[0].isOn = selectedScale == .log
            cell.switchValueDidChangeBlock = {[weak self] (cell, switchControl) in
                guard let strongSelf = self else { return }
                
                strongSelf.selectedScale = switchControl.isOn ? .log : .linear
            }
        case .url:
            cell.textFields?[0].text = UserDefaults.standard.value(forKey: "ChartIQURL") as! String!
            cell.textFieldValueDidEndEditingBlock = { [weak self] (cell, textField) in
                guard let strongSelf = self else { return }
                if let text = textField.text {
                    strongSelf.newUrl = text
                }
            }

        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.reuseIdentifier == Settings.style.cellIdentifier {
            performSegue(withIdentifier: SegueIdentifier.optionsSegue.rawValue, sender: nil)
        }
    }

}
