//
//  UrlManager.swift
//  SMoreTest
//
//  Created by Onseen on 8/6/21.
//

import UIKit

class UrlManager: NSObject {

    static var baseUrl: String {
        get {
            return "https://api-stage.somethingmoreapp.com"
        }
    }
    
    /*************** Messages ****************/
    
    class Message: NSObject {

        public static func uploadPhoto() -> String {
            return String.init(format: "%@/photo/test", baseUrl)
        }

        public static func getPhoto(filename: String) -> String {
            return String.init(format: "%@/photo/test/%@?width=200&height=200", baseUrl, filename)
        }
        
    }
    
}
