//
//  ChartIQQuoteFeedParams.swift
//  ChartIQ
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import Foundation

/// Provides additional information on the data requested by the chart.
open class ChartIQQuoteFeedParams: NSObject {
    
    // MARK: - Properties
    
    open var symbol: String
    open var startDate: String
    open var endDate: String
    open var interval: String
    open var period: Int
    
    // MARK: - Initializers
    
    public init(symbol: String, startDate:String, endDate: String, interval: String, period: Int) {
        self.symbol = symbol
        self.startDate = startDate
        self.endDate = endDate
        self.interval = interval
        self.period = period
    }
}
