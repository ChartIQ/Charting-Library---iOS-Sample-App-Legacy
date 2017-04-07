//
//  Global.swift
//  ChartIQDemo
//
//  Created by Tao Man Kit on 9/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import Foundation
import UIKit

enum Intervals: Int {
    case minute
    case hour
    case day
    case week
    case month
    
    static let count = Intervals.month.rawValue + 1
    
    var intervalCount: Int {
        switch self {
        case .minute: return Intervals.Minute.thirteen.rawValue + 1
        case .hour: return Intervals.Hour.four.rawValue + 1
        case .day: return Intervals.Day.twenty.rawValue + 1
        case .week: return Intervals.Week.one.rawValue + 1
        case .month: return Intervals.Month.one.rawValue + 1
        }
    }
    
    func shortName(rawValue: Int) -> String {
        switch self {
        case .minute: return Intervals.Minute(rawValue: rawValue)!.shortName
        case .hour: return Intervals.Hour(rawValue: rawValue)!.shortName
        case .day: return Intervals.Day(rawValue: rawValue)!.shortName
        case .week: return Intervals.Week(rawValue: rawValue)!.shortName
        case .month: return Intervals.Month(rawValue: rawValue)!.shortName
        }
    }
    
    func period(rawValue: Int) -> (Int, String) {
        switch self {
        case .minute: return Intervals.Minute(rawValue: rawValue)!.period
        case .hour: return Intervals.Hour(rawValue: rawValue)!.period
        case .day: return Intervals.Day(rawValue: rawValue)!.period
        case .week: return Intervals.Week(rawValue: rawValue)!.period
        case .month: return Intervals.Month(rawValue: rawValue)!.period
        }
    }
    
    enum Minute: Int {
        case one
        case three
        case five
        case ten
        case fifteen
        case thirteen
        
        var displayName: String {
            switch self {
            case .one: return "1 Minute"
            case .three: return "3 Minute"
            case .five: return "5 Minute"
            case .ten: return "10 Minute"
            case .fifteen: return "15 Minute"
            case .thirteen: return "30 Minute"
            }
        }
        
        var shortName: String {
            return self.displayName.replacingOccurrences(of: "Minute", with: "MIN")
        }
        
        var period: (Int, String) {
            switch self {
            case .one: return (1, "1")
            case .three: return (1, "3")
            case .five: return (1, "5")
            case .ten: return (1, "10")
            case .fifteen: return (1, "15")
            case .thirteen: return (1, "30")
            }
        }
    }
    
    enum Hour: Int {
        case one
        case four
        
        var displayName: String {
            switch self {
            case .one: return "1 Hour"
            case .four: return "4 Hour"
            }
        }
        
        var shortName: String {
            return self.displayName.uppercased()
        }
        
        var period: (period: Int, interval: String) {
            switch self {
            case .one: return (1, "60")
            case .four: return (1, "240")
            }
        }
    }
    
    enum Day: Int {
        case one
        case two
        case three
        case five
        case ten
        case twenty
        
        var displayName: String {
            switch self {
            case .one: return "1 Day"
            case .two: return "2 Day"
            case .three: return "3 Day"
            case .five: return "5 Day"
            case .ten: return "10 Day"
            case .twenty: return "20 Day"
            }
        }
        
        var shortName: String {
            return self.displayName.uppercased()
        }
        
        var period: (period: Int, interval: String) {
            switch self {
            case .one: return (1, "day")
            case .two: return (2, "day")
            case .three: return (3, "day")
            case .five: return (5, "day")
            case .ten: return (10, "day")
            case .twenty: return (20, "day")
            }
        }
    }
    
    enum Week: Int {
        case one
        
        var displayName: String {
            switch self {
            case .one: return "1 Week"
            }
        }
        
        var shortName: String {
            return self.displayName.uppercased()
        }
        
        var period: (period: Int, interval: String) {
            switch self {
            case .one: return (1, "week")
            }
        }
    }
    
    enum Month: Int {
        case one
        
        var displayName: String {
            switch self {
            case .one: return "1 Month"
            }
        }
        
        var shortName: String {
            return self.displayName.uppercased()
        }
        
        var period: (period: Int, interval: String) {
            switch self {
            case .one: return (1, "month")
            }
        }
    }
}

enum Line: Int {
    case solid
    case dotted
    case dashed
    
    var count: Int {
        switch self {
        case .solid: return 3
        case .dotted: return 2
        case .dashed: return 2
        }
    }
    
    var headerHeight: CGFloat {
        switch self {
        case .solid: return 10
        case .dotted: return 30
        case .dashed: return 30
        }
    }
    
    var pattern: String {
        switch self {
        case .solid: return "solid"
        case .dotted: return "dotted"
        case .dashed: return "dashed"
        }
    }
    
    func image(for row: Int) -> UIImage {
        switch self {
        case .solid:
            switch row {
            case 1: return #imageLiteral(resourceName: "Solid2")
            case 2: return #imageLiteral(resourceName: "Solid3")
            default: return #imageLiteral(resourceName: "Solid1")
            }
        case .dotted:
            switch row {
            case 1: return #imageLiteral(resourceName: "Dotted2")
            default: return #imageLiteral(resourceName: "Dotted1")
            }
        case .dashed:
            switch row {
            case 1: return #imageLiteral(resourceName: "Dashed2")
            default: return #imageLiteral(resourceName: "Dashed1")
            }
        }
    }
    
    func buttonimage(for row: Int) -> UIImage {
        switch self {
        case .solid:
            switch row {
            case 1: return #imageLiteral(resourceName: "LineSolidWhite2")
            case 2: return #imageLiteral(resourceName: "LineSolidWhite3")
            default: return #imageLiteral(resourceName: "LineSolidWhite1")
            }
        case .dotted:
            switch row {
            case 1: return #imageLiteral(resourceName: "LineDottedWhite2")
            default: return #imageLiteral(resourceName: "LineDottedWhite1")
            }
        case .dashed:
            switch row {
            case 0: return #imageLiteral(resourceName: "LineDashedWhite1")
            default: return #imageLiteral(resourceName: "LineDashedWhite1")
            }
        }
    }
    
    static func line(from pattern: String) -> Line? {
        for index in 0 ... Line.dashed.rawValue {
            if Line(rawValue: index)!.pattern == pattern {
                return Line(rawValue: index)
            }
        }
        return nil
    }
}
