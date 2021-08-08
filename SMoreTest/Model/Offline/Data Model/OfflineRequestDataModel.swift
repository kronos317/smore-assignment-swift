//
//  OfflineRequestDataModel.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit
import RealmSwift

class OfflineRequestDataModel: NSObject {

    var id: String! = ""
    
    var enumMethod: EnumNetworkRequestMethodType! = .GET
    var szUrlString: String! = ""
    
    var dictParams: [String: Any]! = [:]
    var nAuthOption: Int! = 0
    var enumStatus: EnumOfflineRequestStatus! = .NEW
    
    override init() {
        self.id = UtilsString.generateObjectId()
        self.enumMethod = .GET
        self.szUrlString = ""
        self.dictParams = [:]
        self.nAuthOption = 0
        self.enumStatus = .NEW
    }
    
    init(method: EnumNetworkRequestMethodType, urlString: String, params: [String: Any], authOption: Int) {
        self.id = UtilsString.generateObjectId()
        self.enumMethod = method
        self.szUrlString = urlString
        self.dictParams = params
        self.nAuthOption = authOption
        self.enumStatus = .NEW
    }
    
    func isActive() -> Bool {
        return self.enumStatus == .NEW
    }
    
}

class RealmOfflineRequestDataModel: Object {

    @objc dynamic var id: String! = ""
    @objc dynamic var method = 0
    @objc dynamic var urlString = ""
    @objc dynamic var json: String! = "{}"
    @objc dynamic var authOption = 0
    @objc dynamic var status = 0
    
    override required init() {
        super.init()
        self.id = ""
        self.method = 0
        self.urlString = ""
        self.json = "{}"
        self.authOption = 0
        self.status = 0
    }

    init(request: OfflineRequestDataModel) {
        super.init()
        self.id = request.id
        self.method = request.enumMethod.rawValue
        self.urlString = request.szUrlString
        self.json = UtilsString.fromDictionary(dictionary: request.dictParams)
        self.authOption = request.nAuthOption
        self.status = request.enumStatus.rawValue
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func serializeToDataModel() -> OfflineRequestDataModel {
        let request = OfflineRequestDataModel()
        request.id = self.id
        request.enumMethod = EnumNetworkRequestMethodType.fromInt(value: self.method)
        request.szUrlString = self.urlString
        request.dictParams = UtilsString.toDictionary(text: self.json)
        request.nAuthOption = self.authOption
        request.enumStatus = EnumOfflineRequestStatus.fromInt(value: self.status)
        return request
    }

}

enum EnumOfflineRequestStatus: Int, CaseIterable {
    
    case NEW = 0
    case IN_PROGRESS = 1
    case COMPLETED = 2
    case FAILED = 3
    
    static func fromInt(value: Int) -> EnumOfflineRequestStatus {
        for status in EnumOfflineRequestStatus.allCases {
            if status.rawValue == value {
                return status
            }
        }
        return .NEW
    }
    
}
