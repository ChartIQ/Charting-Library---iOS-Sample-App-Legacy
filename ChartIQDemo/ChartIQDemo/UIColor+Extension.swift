//
//  UIColor+Extension.swift
//  ChartIQDemo
//
//  Copyright 2012-2019 by ChartIQ, Inc.
//  All rights reserved
//

import Foundation
import UIKit

extension UIColor {
    @objc convenience init(hex: Int) {
        self.init(hex: hex, a: 1.0)
    }
    
    @objc convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }
    
    @objc convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }
    
    @objc convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    @objc convenience init?(hexString: String) {
        guard let hex = hexString.hex else {
            return nil
        }
        self.init(hex: hex)
    }
    
    @objc func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        
        return String(format: "#%06x", rgb)
    }
    
    @objc static func colorsForFillColorPicker() -> [UIColor] {
        return [UIColor(hex: 0x960616), UIColor(hex: 0xea1d2c), UIColor(hex: 0xef6c53), UIColor(hex: 0xe4977c), UIColor.white,
         UIColor(hex: 0xa16118), UIColor(hex: 0xf4932f), UIColor(hex: 0xf8ae63), UIColor(hex: 0xfbc58d), UIColor(hex: 0xcccccc),
         UIColor(hex: 0xcbb920), UIColor(hex: 0xfff126), UIColor(hex: 0xfff371), UIColor(hex: 0xfff69e), UIColor(hex: 0xb7b7b7),
         UIColor(hex: 0x007238), UIColor(hex: 0x00a553), UIColor(hex: 0x43b77a), UIColor(hex: 0x85c99e), UIColor(hex: 0x898989),
         UIColor(hex: 0x00746a), UIColor(hex: 0x00a99c), UIColor(hex: 0x2ebbb3), UIColor(hex: 0x7fcdc7), UIColor(hex: 0x707070),
         UIColor(hex: 0x004c7f), UIColor(hex: 0x0073ba), UIColor(hex: 0x4a8dc8), UIColor(hex: 0x81a8d7), UIColor(hex: 0x555555),
         UIColor(hex: 0x62095f), UIColor(hex: 0x912a8e), UIColor(hex: 0xa665a7), UIColor(hex: 0xbb8dbe), UIColor(hex: 0x1d1d1d),
         UIColor(hex: 0x9c005d), UIColor(hex: 0xe9088c), UIColor(hex: 0xee6fa9), UIColor(hex: 0xf29bc1), UIColor.black,
         UIColor(hex: 0x7DA6F5)]
    }
    
    @objc static func colorsForColorPicker() -> [UIColor] {
        return [UIColor(hex: 0x960616), UIColor(hex: 0xea1d2c), UIColor(hex: 0xef6c53), UIColor(hex: 0xe4977c), UIColor.white,
                UIColor(hex: 0xa16118), UIColor(hex: 0xf4932f), UIColor(hex: 0xf8ae63), UIColor(hex: 0xfbc58d), UIColor(hex: 0xcccccc),
                UIColor(hex: 0xcbb920), UIColor(hex: 0xfff126), UIColor(hex: 0xfff371), UIColor(hex: 0xfff69e), UIColor(hex: 0xb7b7b7),
                UIColor(hex: 0x007238), UIColor(hex: 0x00a553), UIColor(hex: 0x43b77a), UIColor(hex: 0x85c99e), UIColor(hex: 0x898989),
                UIColor(hex: 0x00746a), UIColor(hex: 0x00a99c), UIColor(hex: 0x2ebbb3), UIColor(hex: 0x7fcdc7), UIColor(hex: 0x707070),
                UIColor(hex: 0x004c7f), UIColor(hex: 0x0073ba), UIColor(hex: 0x4a8dc8), UIColor(hex: 0x81a8d7), UIColor(hex: 0x555555),
                UIColor(hex: 0x62095f), UIColor(hex: 0x912a8e), UIColor(hex: 0xa665a7), UIColor(hex: 0xbb8dbe), UIColor(hex: 0x1d1d1d),
                UIColor(hex: 0x9c005d), UIColor(hex: 0xe9088c), UIColor(hex: 0xee6fa9), UIColor(hex: 0xf29bc1), UIColor.black]
    }
}
