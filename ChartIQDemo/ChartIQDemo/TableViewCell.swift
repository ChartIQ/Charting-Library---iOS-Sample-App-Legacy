//
//  TableViewCell.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 10/1/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet var buttons: [UIButton]?
    @IBOutlet var labels: [UILabel]?
    @IBOutlet var textFields: [UITextField]?
    @IBOutlet var views: [UIView]?
    @IBOutlet var imageViews: [UIImageView]?
    @IBOutlet var layoutConstraints: [NSLayoutConstraint]?
    @IBOutlet var stackViews: [UIStackView]?
    @IBOutlet var switchs: [UISwitch]?
    @objc var buttonDidClickBlock: ((TableViewCell, UIButton) -> Void)?
    @objc var switchValueDidChangeBlock: ((TableViewCell, UISwitch) -> Void)?
    @objc var textFieldValueDidEndEditingBlock: ((TableViewCell, UITextField) -> Void)?
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Action
    
    @IBAction func buttonDidClick(_ sender: UIButton) {
        buttonDidClickBlock?(self, sender)
    }
    
    @IBAction func touchIDSwitchValueChanged(_ sender: UISwitch){
        switchValueDidChangeBlock?(self, sender)
    }

}

extension TableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldValueDidEndEditingBlock?(self, textField)
        textField.resignFirstResponder()
    }
    
}
