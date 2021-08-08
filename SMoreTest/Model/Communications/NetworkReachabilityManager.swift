//
//  NetworkReachabilityManager.swift
//  SMoreTest
//
//  Created by Onseen on 8/6/21.
//

import Foundation
import Alamofire

class NetworkReachabilityManager: NSObject {

    public static let sharedInstance = NetworkReachabilityManager()
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager()
    var bOfflineFirst: Bool! = true

    func startNetworkReachabilityObserver() {

        self.reachabilityManager?.listener = { status in
            switch status {

                case .notReachable:
                    UtilsGeneral.log(text: "The network is not reachable")
                    NotificationCenter.default.post(name: .NETWORK_REACHABILITY_CHANGED, object: nil)
                
                case .unknown :
                    UtilsGeneral.log(text: "It is unknown whether the network is reachable")
                    NotificationCenter.default.post(name: .NETWORK_REACHABILITY_CHANGED, object: nil)
                
                case .reachable(.ethernetOrWiFi):
                    UtilsGeneral.log(text: "The network is reachable over the WiFi connection")
                    NotificationCenter.default.post(name: .NETWORK_REACHABILITY_CHANGED, object: nil)
                
                case .reachable(.wwan):
                    UtilsGeneral.log(text: "The network is reachable over the WWAN connection")
                    NotificationCenter.default.post(name: .NETWORK_REACHABILITY_CHANGED, object: nil)
                
            }
        }
        // start listening
        self.reachabilityManager?.startListening()
    }
    
    func isReachable() -> Bool {
        return self.reachabilityManager?.isReachable ?? false
    }
    
}
