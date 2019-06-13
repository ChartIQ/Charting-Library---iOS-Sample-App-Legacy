//
//  OptionsViewController.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 7/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var backButton: UIButton!
    @objc var options = [String]()
    @objc var selectedOption = ""
    @objc var isRightButtonHidden = true
    @objc var rightButtonTitle = ""
    @objc var optionsDidChangeBlock: ((String) -> Void)?
    @objc var rightButtonDidClickBlock: ((String) -> Void)?
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitle(title, for: .normal)
        if !isRightButtonHidden {
            setupNavigationBar()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Layout
    
    @objc func setupNavigationBar() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 26)
        button.backgroundColor = UIColor(hex: 0xde6661)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.setTitle(rightButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 12)
        button.addTarget(self, action: #selector(OptionsViewController.rightBarButtonDidClick), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -5
        navigationItem.rightBarButtonItems = [negativeSpacer, barButton]
    }
    
    // MARK: - Action
    
    @IBAction func rightBarButtonDidClick(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
        rightButtonDidClickBlock?(selectedOption)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionsTableCell", for: indexPath) as! TableViewCell
        let option = options[indexPath.row]
        cell.labels![0].text = option.capitalized
        cell.labels![0].textColor = selectedOption == option ? UIColor(hex: 0x4982f6) : UIColor.black
        cell.accessoryType = selectedOption == option ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = options[indexPath.row]
        optionsDidChangeBlock?(selectedOption)
        tableView.reloadData()
        _ = navigationController?.popViewController(animated: true)
    }

}
