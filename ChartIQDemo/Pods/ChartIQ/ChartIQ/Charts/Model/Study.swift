//
//  Study.swift
//  ChartIQ
//
//  Created by Tao Man Kit on 4/2/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit

open class Study: NSObject {

    open var shortName = ""
    open var name = ""
    open var inputs: [String: Any]?
    open var outputs: [String: Any]?
    open var parameters: [String: Any]?
    
    public init(shortName: String, name: String, inputs: [String: Any]?, outputs: [String: Any]?, parameters: [String: Any]?) {
        super.init()
        
        self.shortName = shortName
        self.name = name
        self.inputs = inputs
        self.outputs = outputs
        self.parameters = parameters
    }
    
}
