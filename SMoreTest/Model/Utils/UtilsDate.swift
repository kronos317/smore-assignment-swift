//
//  UtilsDate.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit

class UtilsDate: NSObject {
    
    public static func fromString(_ value: String?, Format format: String?, TimeZone timeZone: TimeZone?) -> Date? {
        if value == nil || value == "" {
            return nil
        }
        
        let df = DateFormatter()
        df.timeZone = (timeZone == nil) ? TimeZone.current : timeZone!
        df.dateFormat = (format == nil) ? EnumDateTimeFormat.MMddyyyy_hhmma.rawValue : format!
        df.locale = Locale(identifier: "en_US_POSIX")
        
        return df.date(from: value!)
    }
    
    static func toString(_ datetime: Date?, format: String?, timeZone: TimeZone?) -> String {
        guard let _ = datetime else {
            return ""
        }
        let df = DateFormatter()
        df.timeZone = (timeZone == nil) ? TimeZone.current : timeZone!
        df.dateFormat = (format == nil) ? EnumDateTimeFormat.MMddyyyy_hhmma.rawValue : format!
        df.locale = Locale(identifier: "en_US_POSIX")
        
        return df.string(from: datetime!)
    }
    
}

public enum EnumDateTimeFormat: String {
    
    case yyyyMMdd_HHmmss_UTC = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"   // 1989-03-17T11:00:00.000Z
    case yyyyMMdd_HHmmss = "yyyy-MM-dd'T'HH:mm:ss"              // 1989-03-17T11:00:00
    case yyyyMMdd = "yyyy-MM-dd"                                // 1989-03-17
    case MMddyyyy_hhmma = "MM-dd-yyyy hh:mm a"                  // 03-17-1989 02:00 AM
    case MMddyyyy = "MM-dd-yyyy"                                // 03-17-1989
    case MMdd = "MM/dd"                                         // 03/17
    case EEEEMMMMdyyyy = "EEEE, MMMM d, yyyy"                   // Friday, March 17, 1989
    case MMMdyyyy = "MMM d, yyyy"                               // Mar 17, 1989
    case MMMMdd = "MMMM dd"                                     // March 17
    case hhmma = "hh:mm a"                                      // 02:00 AM
    case hhmma_MMMd = "hh:mm a, MMM d"                          // 02:00 AM, Mar 17
    
}
