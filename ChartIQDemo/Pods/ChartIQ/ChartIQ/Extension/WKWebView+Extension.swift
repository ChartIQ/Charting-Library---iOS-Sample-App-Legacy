//
//  WKWebView+Extension.swift
//  ChartIQ
//
//  Created by Tao Man Kit on 23/1/2017.
//  Copyright © 2017 ROKO. All rights reserved.
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
