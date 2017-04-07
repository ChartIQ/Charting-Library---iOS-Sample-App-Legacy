//
//  UIViewController+Extension.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 8/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit

extension UIViewController {
    
    @IBAction func dismissBarButtonDidClick(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
