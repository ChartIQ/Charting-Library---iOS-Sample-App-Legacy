//
//  ChartIQData.swift
//  ChartIQ
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import Foundation

/// Properly formatted OHLC quote objects 
open class ChartIQData: NSObject {
    
    // MARK: - Properties
    
    open var date: Date
    open var open: Double
    open var high: Double
    open var low: Double
    open var close: Double
    open var volume: Double
    open var adj_close: Double
    
    // MARK: - Initializers
    
    public init(date: Date, open: Double, high: Double, low: Double, close: Double, volume: Double, adj_close: Double) {
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.adj_close = adj_close
    }
    
    // MARK: - Helper
    
    func toDictionary() -> [String: Any]{
        let _date = ChartUtils.chartDateFormatter.string(from: date)
        return ["DT": _date, "Open": open, "High": high, "Low": low, "Close": close, "Volume": volume, "Adj_Close": adj_close]
    }
    
    func toJSONString() -> String{
        let data = try! JSONSerialization.data(withJSONObject: self.toDictionary(), options: .prettyPrinted)
        return String(data: data, encoding: .utf8) ?? ""
    }

}
