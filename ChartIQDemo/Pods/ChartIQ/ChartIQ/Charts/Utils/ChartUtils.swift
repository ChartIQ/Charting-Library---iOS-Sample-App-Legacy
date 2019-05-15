//
//  ChartUtils.swift
//  ChartIQ
//
//  Created by Tao Man Kit on 17/1/2017.
//  Copyright © 2017 ROKO. All rights reserved.
//

import Foundation

open class ChartUtils {
    
    fileprivate static let _defaultDateFormatter = DateFormatter()
    
    public static var chartDateFormatter: DateFormatter {
        _defaultDateFormatter.timeZone = TimeZone(identifier: "UTC")
        _defaultDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'" // "YYYY-MM-dd"
        _defaultDateFormatter.locale = Locale(identifier: "en")
        return _defaultDateFormatter
    }
    
//    func getWiFiAddress() -> String? {
//        var address : String?
//        
//        // Get list of all interfaces on the local machine:
//        var ifaddr : UnsafeMutablePointer<ifaddrs>?
//        guard getifaddrs(&ifaddr) == 0 else { return nil }
//        guard let firstAddr = ifaddr else { return nil }
//        
//        // For each interface ...
//        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
//            let interface = ifptr.pointee
//            
//            // Check for IPv4 or IPv6 interface:
//            let addrFamily = interface.ifa_addr.pointee.sa_family
//            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
//                
//                // Check interface name:
//                let name = String(cString: interface.ifa_name)
//                if  name == "en0" {
//                    
//                    // Convert interface address to a human readable string:
//                    var addr = interface.ifa_addr.pointee
//                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
//                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
//                                &hostname, socklen_t(hostname.count),
//                                nil, socklen_t(0), NI_NUMERICHOST)
//                    address = String(cString: hostname)
//                }
//            }
//        }
//        freeifaddrs(ifaddr)
//        
//        return address
//    }
}
