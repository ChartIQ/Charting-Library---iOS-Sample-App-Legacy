//
//  Symbol.swift
//  ChartIQ
//
//  Created by Tao Man Kit on 31/1/2017.
//  Copyright © 2017 ROKO. All rights reserved.
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
