//
//  StudyDetailViewController.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 6/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit
import ChartIQ

class StudyDetailViewController: UITableViewController {

    // MARK: - Properties
    
    enum SegueIdentifier: String {
        case optionsSegue = "OptionsSegue"
    }
    
    enum OptionType: String {
        case select = "select"
        case number = "number"
        case checkbox = "checkbox"
        case color = "color"
        case text = "text"
        case colorText = "colorText"
        
        var cellIdentifier: String {
            switch self {
            case .select: return "StudyListTableCell"
            case .number: return "StudyValueTableCell"
            case .text: return "StudyValueTableCell"
            case .checkbox: return "StudySwitchTableCell"
            case .color: return "StudyColorTableCell"
            case .colorText: return "StudyTextAndColorTableCell"
            }
        }
    }
    
    var colorPicker: ColorPickerView!
    var selectedColorIndex = -1
    var study: Study!
    var inputParameter: [[String: Any]]!
    var outputParameter: [[String: Any]]!
    var paramParameter: [[String: Any]]!
    var removeStudyBlock: ((Study) -> Void)?
    var editStudyBlock: ((Study) -> Void)?
    var selectedCellIndex = -1;
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupColorPicker()
        NotificationCenter.default.addObserver(self, selector: #selector(StudyDetailViewController.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        colorPicker.isHidden = true
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier.flatMap(SegueIdentifier.init) else { return }
        
        switch identifier {
        case .optionsSegue:
            guard let cell = sender as? TableViewCell, let name = cell.labels![0].text else { return }
            
            for parameter in inputParameter {
                if parameter["name"] as? String == name, let options = parameter["options"] as? [String: Any]{
                    let viewController = segue.destination as? OptionsViewController
                    viewController?.selectedOption = parameter["value"] as? String ?? ""
                    viewController?.options = options.map { $0.key }
                    viewController?.optionsDidChangeBlock = {[weak self] (option)  in
                        guard let strongSelf = self else { return }
                        for (index, var inputs) in strongSelf.inputParameter.enumerated() {
                            if inputs["name"] as? String == name {
                                inputs["value"] = option
                                strongSelf.inputParameter![index] = inputs
                                break
                            }
                        }
                    }
                    break
                }
            }
        }
    }

    // MARK: - Layout
    
    func setupNavigationBar() {
        let editButton = UIButton(type: .custom)
        editButton.frame = CGRect(x: 0, y: 0, width: 107, height: 26)
        editButton.backgroundColor = UIColor(hex: 0xde6661)
        editButton.layer.cornerRadius = 4
        editButton.layer.masksToBounds = true
        editButton.setTitle("Remove Study", for: .normal)
        editButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 12)
        editButton.addTarget(self, action: #selector(StudyDetailViewController.editButtonDidClick), for: .touchUpInside)
        let editBarButton = UIBarButtonItem(customView: editButton)
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -5
        navigationItem.rightBarButtonItems = [negativeSpacer, editBarButton]
    }
    
    func setupColorPicker() {
        colorPicker = Bundle.main.loadNibNamed("ColorPickerView", owner: self, options: nil)![0] as? ColorPickerView
        tableView.addSubview(colorPicker)
        colorPicker.colorDidChangeBlock = { [weak self] (color) in
            guard let strongSelf = self else { return }
            if strongSelf.selectedCellIndex > (strongSelf.outputParameter.count + strongSelf.inputParameter.count) {
                var parameter = strongSelf.paramParameter[strongSelf.selectedColorIndex]
                parameter["color"] = color.toHexString()
                strongSelf.paramParameter![strongSelf.selectedCellIndex - (strongSelf.inputParameter.count + strongSelf.outputParameter.count)] = parameter
                strongSelf.tableView.reloadData()
                strongSelf.colorPicker.isHidden = true
            } else {
                var output = strongSelf.outputParameter[strongSelf.selectedColorIndex]
                output["color"] = color.toHexString()
                strongSelf.outputParameter![strongSelf.selectedCellIndex - strongSelf.inputParameter.count] = output
                strongSelf.tableView.reloadData()
                strongSelf.colorPicker.isHidden = true
            }
        }
    }
    
    // MARK: - Helper
    
    func keyboardWillShow() {
        colorPicker.isHidden = true
    }

    func updateStudyParameters() {
        var inputs = [String: Any]()
        for input in inputParameter {
            inputs[input["name"] as! String] = input["value"]!
        }
        var outputs = [String: Any]()
        for output in outputParameter {
            outputs[output["name"] as! String] = output["color"]!
        }
        var parameters = [String: Any]()
        for parameter in paramParameter {
            parameters[parameter["name"] as! String] = parameter["value"]!
        }
        study.inputs = inputs
        study.outputs = outputs
        study.parameters = parameters
    }
    
    func resetStudyParameters() {
        for (index, var inputs) in inputParameter.enumerated() {
            inputs["value"] = inputs["defaultInput"]
            inputParameter![index] = inputs
        }
        for (index, var outputs) in outputParameter.enumerated() {
            outputs["value"] = outputs["defaultInput"]
            outputParameter![index] = outputs
        }
    }
    
    // MARK: - Action
    
    @IBAction func editButtonDidClick(_ sender: UIButton) {
        removeStudyBlock?(study)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyButtonDidClick(_ sender: UIButton) {
        view.endEditing(true)
        updateStudyParameters()
        editStudyBlock?(study)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonDidClick(_ sender: UIButton) {
        view.endEditing(true)
        resetStudyParameters()
        tableView.reloadData()
    }
    
    // MARK: - ScrollViewDelegate
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        colorPicker.isHidden = true
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputParameter.count + outputParameter.count + paramParameter.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudyTableHeader") as! TableViewCell
        cell.labels?[0].text = study.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        var parameter: [String: Any]!
        if inputParameter.count > index {
            parameter = inputParameter[index]
        } else if inputParameter.count + outputParameter.count > index {
            parameter = outputParameter[index - inputParameter.count]
        } else {
            parameter = paramParameter[index - (inputParameter.count + outputParameter.count)]
        }
        var type = parameter["type"] != nil ? parameter["type"] as! String : "color"
        if parameter["color"] != nil && parameter["type"] != nil && parameter["type"] as! String == "text" { type = "colorText" }
        let optionType = OptionType(rawValue: type)!
        let cell = tableView.dequeueReusableCell(withIdentifier: optionType.cellIdentifier, for: indexPath) as! TableViewCell
        cell.labels?[0].text = parameter["name"] as? String ?? ""
        switch optionType {
        case .select:
            cell.labels?[1].text = (parameter["value"] as? String)?.capitalized ?? ""
        case .number, .text:
            cell.textFields![0].keyboardType = optionType == .number ? .numberPad : .default
            cell.textFields?[0].text = optionType == .number ? String(parameter["value"] as? Float ?? 0) : parameter["value"] as? String ?? ""
            cell.textFieldValueDidEndEditingBlock = {[weak self] (cell, textField) in
                guard let strongSelf = self else { return }
                let name = cell.labels![0].text ?? ""
                for (index, var inputs) in strongSelf.inputParameter.enumerated() {
                    if inputs["name"] as? String == name {
                        if optionType == .number {
                            inputs["value"] = Float(textField.text ?? "0")
                        } else {
                            inputs["value"] = textField.text ?? ""
                        }
                        strongSelf.inputParameter![index] = inputs
                        break
                    }
                }
            }
        case .checkbox:
            cell.switchs?[0].isOn = parameter["value"] as? Bool ?? false
            cell.switchValueDidChangeBlock = {[weak self] (cell, switchControl) in
                guard let strongSelf = self else { return }
                strongSelf.view.endEditing(true)
                let name = cell.labels![0].text ?? ""
                for (index, var inputs) in strongSelf.inputParameter.enumerated() {
                    if inputs["name"] as? String == name {
                        inputs["value"] = switchControl.isOn
                        strongSelf.inputParameter![index] = inputs
                        break
                    }
                }
            }
        case .color:
            let color = parameter["color"] as? String
            cell.buttons?[0].backgroundColor = UIColor(hexString: color != nil ? color!.replacingOccurrences(of: "#", with: "") : "000000")
            cell.buttonDidClickBlock = {[weak self] (cell, button) in
                guard let strongSelf = self else { return }
                strongSelf.selectedCellIndex = index;
                strongSelf.colorPicker.isHidden = !strongSelf.colorPicker.isHidden
                if !strongSelf.colorPicker.isHidden {
                    let rect = tableView.rectForRow(at: indexPath)
                    var rectOfCellInSuperview = tableView.convert(rect, to: tableView.superview)
                    rectOfCellInSuperview.origin.y -= 64
                    let direction = rectOfCellInSuperview.midY >= tableView.frame.height / 2 ? ColorPickerView.Direction.top : ColorPickerView.Direction.bottom
                    strongSelf.colorPicker.frame = CGRect(x: tableView.frame.width - 153 - 15, y: direction == .top ? rectOfCellInSuperview.midY - 294 + tableView.contentOffset.y  : rectOfCellInSuperview.midY + 19 + tableView.contentOffset.y , width: 153, height: 260)
                    strongSelf.colorPicker.direction = direction
                    strongSelf.selectedColorIndex = index - strongSelf.inputParameter.count
                }
            }
        case .colorText:
            let color = parameter["color"] as? String
            cell.buttons?[0].backgroundColor = UIColor(hexString: color != nil ? color!.replacingOccurrences(of: "#", with: "") : "000000")
            cell.buttonDidClickBlock = {[weak self] (cell, button) in
                guard let strongSelf = self else { return }
                strongSelf.selectedCellIndex = index;
                strongSelf.colorPicker.isHidden = !strongSelf.colorPicker.isHidden
                if !strongSelf.colorPicker.isHidden {
                    let rect = tableView.rectForRow(at: indexPath)
                    var rectOfCellInSuperview = tableView.convert(rect, to: tableView.superview)
                    rectOfCellInSuperview.origin.y -= 64
                    let direction = rectOfCellInSuperview.midY >= tableView.frame.height / 2 ? ColorPickerView.Direction.top : ColorPickerView.Direction.bottom
                    strongSelf.colorPicker.frame = CGRect(x: tableView.frame.width - 153 - 15, y: direction == .top ? rectOfCellInSuperview.midY - 294 + tableView.contentOffset.y  : rectOfCellInSuperview.midY + 19 + tableView.contentOffset.y , width: 153, height: 260)
                    strongSelf.colorPicker.direction = direction
                    strongSelf.selectedColorIndex = index - (strongSelf.inputParameter.count + strongSelf.outputParameter.count)
                }
            }
            cell.textFields![0].keyboardType = .numberPad
            cell.textFields?[0].text = String(parameter["value"] as? Int ?? 0)
            cell.textFieldValueDidEndEditingBlock = {[weak self] (cell, textField) in
                guard let strongSelf = self else { return }
                let name = cell.labels![0].text ?? ""
                for (index, var params) in strongSelf.paramParameter.enumerated() {
                    if params["name"] as? String == name {
                        params["value"] = Int(textField.text ?? "0")
                        strongSelf.paramParameter![index] = params
                        break
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.reuseIdentifier == OptionType.select.cellIdentifier {
            view.endEditing(true)
            performSegue(withIdentifier: SegueIdentifier.optionsSegue.rawValue, sender: cell)
        }
    }


}
