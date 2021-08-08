//
//  MessageDataModel.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit
import RealmSwift

class MessageDataModel: NSObject {

    var id: String! = ""
    var enumType: EnumMessageType! = .NONE
    
    var szMessage: String! = ""
    var modelMedia: MessageMediaDataModel! = MessageMediaDataModel()
    
    var date: Date? = nil
    var enumStatus: EnumMessageStatus! = .NEW
    
    func initialize() {
        self.id = UtilsString.generateObjectId()
        self.enumType = .NONE
        
        self.szMessage = ""
        self.modelMedia = MessageMediaDataModel()
        
        self.date = nil
        self.enumStatus = .NEW
    }
    
    func serialize() -> [String: Any] {
        return [
            "id": self.id ?? "",
            "type": self.enumType.rawValue,
            "message": self.szMessage ?? "",
            "filename": self.modelMedia.szFileName ?? "",
            "datetime": UtilsDate.toString(self.date, format: EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.rawValue, timeZone: .UTC),
            "status": self.enumStatus.rawValue
        ]
    }
    
    func deserialize(dictionary: [String: Any]?) {
        self.initialize()
        guard let dictionary = dictionary else {
            return
        }
        
        self.id = UtilsString.toString(dictionary["id"])
        self.szMessage = UtilsString.toString(dictionary["message"])
        self.modelMedia.szFileName = UtilsString.toString(dictionary["filename"])
        self.enumType = EnumMessageType.fromString(UtilsString.toString(dictionary["type"]))
        self.date = UtilsDate.fromString(UtilsString.toString(dictionary["datetime"]), Format: EnumDateTimeFormat.yyyyMMdd_HHmmss_UTC.rawValue, TimeZone: .UTC)
        self.enumStatus = EnumMessageStatus.fromString(UtilsString.toString(dictionary["status"]))
    }
    
    func deserializeMedia(dictionary: [String: Any]?) {
        guard let dictionary = dictionary else {
            return
        }        
        self.modelMedia.szFileName = UtilsString.toString(dictionary["filename"])
    }
    
}

class RealmMessageDataModel: Object {
    
    @objc dynamic var id: String! = ""
    @objc dynamic var json: String! = "{}"
    
    override required init() {
        super.init()
        self.id = ""
        self.json = "{}"
    }

    init(messageId: String, dictionary: [String: Any]) {
        super.init()
        self.id = messageId
        self.json = UtilsString.fromDictionary(dictionary: dictionary)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func serializeToDataModel() -> MessageDataModel {
        let message = MessageDataModel()
        message.deserialize(dictionary: UtilsString.toDictionary(text: self.json))
        return message
    }
}

enum EnumMessageType: String, CaseIterable {
    
    case NONE = ""
    case TEXT = "text"
    case PHOTO = "photo"
    
    static func fromString(_ string: String?) -> EnumMessageType {
        guard let string = string else {
            return .NONE
        }
        
        for t in EnumMessageType.allCases {
            if t.rawValue.caseInsensitiveCompare(string) == .orderedSame {
                return t
            }
        }
        
        return .NONE
    }
    
}

enum EnumMessageStatus: String, CaseIterable {
    
    case NEW = "new"
    case DELIVERED = "delivered"
    case READ = "read"
    case DELIVERY_FAILED = "delivery_failed"
    
    static func fromString(_ string: String?) -> EnumMessageStatus {
        guard let string = string else {
            return .NEW
        }
        
        for s in EnumMessageStatus.allCases {
            if s.rawValue.caseInsensitiveCompare(string) == .orderedSame {
                return s
            }
        }
        
        return .NEW
    }
    
}
