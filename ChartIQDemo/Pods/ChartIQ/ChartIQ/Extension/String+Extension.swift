//
//  String+Extension.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 12/1/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import Foundation

extension String: Error {
    var hex: Int? {
        return Int(self, radix: 16)
    }
}
