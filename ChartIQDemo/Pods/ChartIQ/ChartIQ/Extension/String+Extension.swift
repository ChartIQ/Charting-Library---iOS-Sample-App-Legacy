//
//  String+Extension.swift
//  ChartIQDemo
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import Foundation

extension String: Error {
    var hex: Int? {
        return Int(self, radix: 16)
    }
}
