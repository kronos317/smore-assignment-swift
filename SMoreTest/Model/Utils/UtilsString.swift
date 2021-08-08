//
//  UtilsString.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit

class UtilsString: NSObject {
    
    // MARK: String Parsers
    public static func toString(_ value: Any?) -> String! {
        guard let _ = value else {
            return ""
        }
        if let _ = value as? NSNull {
            return ""
        }
        return value as? String ?? ""
    }
    
    public static func toString(_ value: Any?, DefaultValue defaultValue: String) -> String! {
        guard let _ = value else {
            return defaultValue
        }
        if let _ = value as? NSNull {
            return defaultValue
        }
        return value as? String ?? defaultValue
    }
    
    public static func toInt(_ value: Any?, DefaultValue defaultValue: Int?) -> Int! {
        let defValue: Int! = defaultValue ?? 0
        if let _ = value as? NSNull {
            return defValue
        }
        guard let _ = value else {
            return defValue
        }
        
        if let v = value as? Int {
            return v
        }
        
        let valueString = String.init(format: "%@", value! as! CVarArg)
        if let v = Int(valueString) {
            return v
        }
        return defValue
    }
    
    public static func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length - 1).map{ _ in letters.randomElement()! })
    }
    
    public static func fromDictionary(dictionary: [String: Any]) -> String {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
            let theJSONText = String(data: theJSONData, encoding: .utf8)
            return theJSONText ?? "{}"
        }
        return "{}"
    }
    
    public static func toDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public static func generateObjectId() -> String {
        let time = String(Int(Date().timeIntervalSince1970), radix: 16, uppercase: false)
        let machine = String(Int.random(in: 100000 ..< 999999))
        let pid = String(Int.random(in: 1000 ..< 9999))
        let counter = String(Int.random(in: 100000 ..< 999999))
        return time + machine + pid + counter
    }
    
}
