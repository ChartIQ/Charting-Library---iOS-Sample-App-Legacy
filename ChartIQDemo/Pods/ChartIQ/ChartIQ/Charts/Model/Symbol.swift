//
//  Symbol.swift
//  ChartIQ
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import UIKit

open class Symbol: NSObject {
    
    open var symbol = ""
    open var name = ""
    
    public init(symbol: String, name: String) {
        super.init()
        
        self.symbol = symbol
        self.name = name
    }
    
}
