//
//  UIViewController+Extension.swift
//  ChartIQDemo
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import UIKit

extension UIViewController {
    
    @IBAction func dismissBarButtonDidClick(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
