//
//  CrosshairHUD.swift
//  ChartIQ
//
//  Created by Tao Man Kit on 7/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import Foundation

open class CrosshairHUD: NSObject {
    
    // MARK: - Properties
    open var open = ""
    open var high = ""
    open var low = ""
    open var close = ""
    open var volume = ""

    public init(open: String, high: String, low: String, close: String, volume: String) {
        super.init()
        
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
    
}
