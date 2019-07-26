//
//  SearchStudiesViewController.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 1/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit
import ChartIQ

class SearchStudiesViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet weak var searchTextField: UITextField!
    @objc var editButton: UIButton!
    @objc var negativeSpacer: UIBarButtonItem!
    @objc var editBarButton: UIBarButtonItem!
    @objc var allStudies = [Study]()
    @objc var addedStudies = [Study]()
    @objc var selectedStudies = [Study]()
    @objc var selectedAddedStudies = [Study]()
    @objc var filteredStudies = [Study]()
    @objc var isFiltering: Bool {
        return searchTextField.isUserInteractionEnabled && !(searchTextField.text ?? "").isEmpty
    }
    
    @objc var studiesDidChangeBlock: (([String]) -> Void)?
    @objc var addStudiesBlock: (([Study]) -> Void)?
    @objc var removeStudiesBlock: (([Study]) -> Void)?
    @objc var getAddedStudiesBlock: (() -> [Study])?
    var getStudyParameterBlock: ((String) -> (input: Any?, output: Any?, parameters: Any?))?
    @objc var editStudiesBlock: ((Study) -> Void)?
    
    enum Studies: Int {
        case active
        case available
        
        static let count = Studies.available.rawValue + 1
        
        var displayName: String {
            switch self {
            case .active: return "ACTIVE STUDIES"
            case .available: return "ADD AVAILABLE STUDIES"
            }
        }
    }
    
    enum SegueIdentifier: String {
        case studyDetailSegue = "StudyDetailSegue"
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for studies", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white] as [NSAttributedString.Key: Any])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addedStudies = getAddedStudiesBlock?() ?? [Study]()
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        selectedAddedStudies.removeAll()
        selectedStudies.removeAll()
        updateNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier.flatMap(SegueIdentifier.init) else { return }
        
        switch identifier {
        case .studyDetailSegue:
            guard let cell = sender as? TableViewCell, let name = cell.labels![0].text else { return }
            let viewController = segue.destination as? StudyDetailViewController
            let study = addedStudies.filter{ $0.name == name }[0]
            viewController?.study = study
            viewController?.removeStudyBlock = {[weak self] (study)  in
                guard let strongSelf = self else { return }
                strongSelf.removeStudiesBlock?([study])
            }
            let parameter = getStudyParameterBlock?(study.name)
            viewController?.inputParameter = parameter?.input as? [[String: Any]] ?? [[String: Any]]()
            viewController?.outputParameter = parameter?.output as? [[String: Any]] ?? [[String: Any]]()
            viewController?.paramParameter = parameter?.parameters as? [[String: Any]] ?? [[String: Any]]()
            viewController?.editStudyBlock = {[weak self] (study)  in
                guard let strongSelf = self else { return }
                strongSelf.editStudiesBlock?(study)
            }
        }
    }
    
    // MARK: - layout
    
    @objc func updateNavigationBar() {
        if editBarButton == nil {
            editButton = UIButton(type: .custom)
            editButton.frame = CGRect(x: 0, y: 0, width: 91, height: 26)
            editButton.layer.cornerRadius = 4
            editButton.layer.masksToBounds = true
            editButton.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 12)
            editButton.addTarget(self, action: #selector(SearchStudiesViewController.editButtonDidClick), for: .touchUpInside)
            editBarButton = UIBarButtonItem(customView: editButton)
            negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
            negativeSpacer.width = -5
        }
        if !selectedStudies.isEmpty || !selectedAddedStudies.isEmpty{
            editButton.setTitle(!selectedStudies.isEmpty ? "Add" : "Remove", for: .normal)
            editButton.backgroundColor = !selectedStudies.isEmpty ?  UIColor(hex: 0x4982f6) : UIColor(hex: 0xde6661)
            navigationItem.rightBarButtonItems = [negativeSpacer, editBarButton]
            if !isFiltering {
                navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "Close")
                searchTextField.backgroundColor = UIColor.clear
                searchTextField.clearButtonMode = .never
                searchTextField.isUserInteractionEnabled = false
                searchTextField.text = "\(!selectedStudies.isEmpty ? selectedStudies.count : selectedAddedStudies.count) Studies"
            }
        } else {
            navigationItem.rightBarButtonItems = nil
            navigationItem.leftBarButtonItem?.image = #imageLiteral(resourceName: "Back")
            searchTextField.backgroundColor = UIColor(hex: 0x2b343d)
            searchTextField.clearButtonMode = .always
            searchTextField.isUserInteractionEnabled = true
            searchTextField.text = ""
        }
    }
    
    // MARK: - Helper
    
    @objc func filterStudies(by keyword: String) {
        filteredStudies = allStudies.filter({(study) -> Bool in
            return study.name.lowercased().range(of: keyword.lowercased()) != nil
        })
        tableView.reloadData()
    }

    // MARK: - Action
    
    @IBAction func editButtonDidClick(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        if !selectedStudies.isEmpty {
            addStudiesBlock?(selectedStudies)
            selectedStudies.removeAll()
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        } else if !selectedAddedStudies.isEmpty {
            removeStudiesBlock?(selectedAddedStudies)
            selectedAddedStudies.removeAll()
        }
        updateNavigationBar()
        tableView.reloadData()
    }
    
    @IBAction override func dismissBarButtonDidClick(_ sender: UIButton) {
        if !selectedAddedStudies.isEmpty || !selectedStudies.isEmpty {
            selectedAddedStudies.removeAll()
            selectedStudies.removeAll()
            updateNavigationBar()
            tableView.reloadData()
        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func searchTextFieldValueDidChange(_ sender: UITextField) {
        if isFiltering {
            filterStudies(by: sender.text ?? "")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Studies.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Studies(rawValue: section)! {
        case .active: return addedStudies.count
        case .available:
            if isFiltering {
                return filteredStudies.count
            } else {
                return allStudies.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudyTableHeader") as! TableViewCell
        cell.labels?[0].text = Studies(rawValue: section)!.displayName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudyTableCell", for: indexPath) as! TableViewCell
        
        switch Studies(rawValue: indexPath.section)! {
        case .active:
            let study = addedStudies[indexPath.row]
            cell.buttons?[0].isHidden = false
            cell.buttonDidClickBlock = { [weak self] (cell, _) in
                guard let strongSelf = self else { return }
                strongSelf.performSegue(withIdentifier: SegueIdentifier.studyDetailSegue.rawValue, sender: cell)
            }
            cell.backgroundColor = selectedAddedStudies.contains(study) ? UIColor(hex: 0xecf2fe) : UIColor.white
            cell.labels?[0].text = study.name
        case .available:
            var study: Study! = nil
            if isFiltering {
                study = filteredStudies[indexPath.row]
            } else {
                study = allStudies[indexPath.row]
            }
            cell.buttons?[0].isHidden = true
            cell.backgroundColor = selectedStudies.contains(study) ?UIColor(hex: 0xecf2fe) : UIColor.white
            cell.labels?[0].text = study.name
        }
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Studies(rawValue: indexPath.section)! {
        case .active:
            selectedStudies.removeAll()
            if let index = selectedAddedStudies.firstIndex(of: addedStudies[indexPath.row]) {
                selectedAddedStudies.remove(at: index)
            } else {
                selectedAddedStudies.append(addedStudies[indexPath.row])
            }
        case .available:
            selectedAddedStudies.removeAll()
            var studies = allStudies
            if isFiltering {
                studies = filteredStudies
            }
            if let index = selectedStudies.firstIndex(of: studies[indexPath.row]) {
                selectedStudies.remove(at: index)
            } else {
                selectedStudies.append(studies[indexPath.row])
            }
        }
        updateNavigationBar()
        tableView.reloadData()
    }
    
}

extension SearchStudiesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let keyword = textField.text, !keyword.isEmpty {
            textField.resignFirstResponder()
            filterStudies(by: keyword)
        }
        return true
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
