//
//  AppManager.swift
//  SMoreTest
//
//  Created by Onseen on 8/6/21.
//

import UIKit
import IQKeyboardManagerSwift

class AppManager: NSObject {

    public static let sharedInstance = AppManager()
    
    func initializeManagersAfterLaunch() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 20
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        OfflineManager.sharedInstance.initialize()
    }
    
}
