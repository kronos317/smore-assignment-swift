//
//  UtilsGeneral.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit

class UtilsGeneral: NSObject {

    static let LOG_MAXLENGTH = 512
    
    public static func log(text: String) {
        var logText = text
        if logText.count > UtilsGeneral.LOG_MAXLENGTH {
            logText = logText.truncate(toLength: UtilsGeneral.LOG_MAXLENGTH, trailing: "... {{Log Text is too long}}")
        }
        print(logText)
    }
    
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}

class UIConfig: NSObject {
    
    enum StoryboardName: String {
        
        case MAIN = "Main"
        
    }
    
    enum StoryboardID: String {
        
        /// Main
        case MAIN_HOME = "Storyboard.Main.Home"
        
        /// Chats
        case CHAT_PHOTOPOPUP = "Storyboard.Main.ChatPhotoPopup"
        case CHAT_ROOM = "Storyboard.Main.ChatRoom"
        
    }
    
    enum TableViewCellNibName: String {
        
        // MARK: Messages
        case MESSAGES_YOURITEM_TEXT = "MessageYourTextTableViewCell"
        case MESSAGES_MYITEM_TEXT = "MessageMyTextTableViewCell"
        case MESSAGES_MYITEM_PHOTO = "MessageMyPhotoTableViewCell"
        
    }
    
    enum TableViewCellID: String {
        
        // MARK: Messages
        case MESSAGES_YOURITEM_TEXT = "TableViewCell.Chat.MessageYourText"
        case MESSAGES_MYITEM_TEXT = "TableViewCell.Chat.MessageMyText"
        case MESSAGES_MYITEM_PHOTO = "TableViewCell.Chat.MessageMyPhoto"
        
    }
}
