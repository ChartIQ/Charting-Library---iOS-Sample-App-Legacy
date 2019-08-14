//
//  WKWebView+Extension.swift
//  ChartIQ
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import Foundation
import UIKit
import WebKit

extension WKWebView {
    func evaluateJavaScriptWithReturn(_ javaScriptString: String) -> String? {
        var finished = false
        var jsValue: String?
        
        evaluateJavaScript(javaScriptString) { (result, error) in
            if error == nil {
                if result != nil {
                    jsValue = result as? String
                }
            } else {
                jsValue = nil
            }
            finished = true
        }
        
        while !finished {
            RunLoop.current.run(mode: RunLoop.Mode.default, before: Date.distantFuture)
        }
        
        return jsValue
    }
}
