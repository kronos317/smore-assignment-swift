//
//  MessageManager.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit
import Alamofire

class MessageManager: NSObject {

    public static let sharedInstance = MessageManager()
    var arrayMessages: [MessageDataModel]! = []
    
    func initialize() {
        self.arrayMessages = []
    }
    
    // MARK: - Utils
    
    func addMessage(message: MessageDataModel) {
        if message.id.isEmpty {
            return
        }
        
        self.arrayMessages.append(message)
    }
    
    func sort() {
        self.arrayMessages = self.arrayMessages.sorted {
            guard let date0 = $0.date else {
                return false
            }
            guard let date1 = $1.date else {
                return true
            }
            
            return date0 < date1
        }
    }
    
    // MARK: - Requests
    
    func requestGetMessages(callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        self.realm_requestReadMessages(callback: callback)
    }
    
    func requestSendMessage(message: MessageDataModel, callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        self.realm_saveMessage(message: message)
        callback?(NetworkResponseDataModel<Any>.instanceForSuccess())
    }
    
    func requestUploadPhoto(message: MessageDataModel, image: UIImage, callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        let urlString = UrlManager.Message.uploadPhoto()
        message.modelMedia.imageCache = image
        
        NetworkManager.UPLOAD(endPoint: urlString, fileName: "photo.png", mimeType: EnumMediaMimeType.PNG.rawValue, file: image.pngData()! /*image.jpegData(compressionQuality: 1.0)!*/, authOptions: EnumNetworkAuthOptions.AUTH_NONE.rawValue) { (response) in
            if response.isSuccess() {
                message.enumStatus = .DELIVERED
                message.deserializeMedia(dictionary: response.payload)
                
                /// Save to disk for offline mode
                if OfflineManager.sharedInstance.saveImageToDisk(image: image, path: message.modelMedia.getLocalFilePath()) == true {
                    callback?(response)
                }
                else {
                    let responseNew = NetworkResponseDataModel<Any>.instanceForFailure()
                    responseNew.errorMessage = "Failed to save image on disk."
                    callback?(responseNew)
                }
            }
            else {
                callback?(response)
            }
        }
    }
    
    func requestDownloadPhoto(message: MessageDataModel, callback: ((NetworkResponseDataModel<String>) -> ())?) {
        if message.enumType != .PHOTO {
            callback?(NetworkResponseDataModel<String>.instanceForFailure())
            return
        }
        
        let filepath = message.modelMedia.getLocalFilePath()
        
        let urlString = UrlManager.Message.getPhoto(filename: message.modelMedia.szFileName)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (filepath, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        NetworkManager.DOWNLOAD(endpoint: urlString, downloadDestination: destination) { response in
            if response.isSuccess(), let downloadedUrl = response.parsedObject {
                message.modelMedia.imageCache = UIImage(contentsOfFile: downloadedUrl)
            }
            callback?(response)
        }
    }
    
    func requestDownloadAllPhotos(callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        let messages = self.arrayMessages.filter({ $0.enumType == .PHOTO })
        if messages.count == 0 {
            callback?(NetworkResponseDataModel<Any>.instanceForSuccess())
            return
        }
        
        let requestsGroup = DispatchGroup()
        let _ = DispatchQueue.global(qos: .userInitiated)
        var allSucceeded: Bool = true
        
        DispatchQueue.concurrentPerform(iterations: messages.count) { (index) in
            let message = messages[index]
            requestsGroup.enter()
            self.requestDownloadPhoto(message: message) { response in
                if response.isSuccess() == false {
                    allSucceeded = false
                }
                
                requestsGroup.leave()
            }
        }
        
        requestsGroup.notify(queue: DispatchQueue.global()) {
            if allSucceeded == true {
                callback?(NetworkResponseDataModel<Any>.instanceForSuccess())
            }
            else {
                callback?(NetworkResponseDataModel<Any>.instanceForFailure())
            }
        }

    }
    
}

// MARK: - Offline

extension MessageManager {
    
    func realm_saveMessage(message: MessageDataModel) {
        let realmMessage = RealmMessageDataModel(messageId: message.id, dictionary: message.serialize())
        OfflineManager.sharedInstance.write(object: realmMessage)
    }
    
    /// Requests
    
    func realm_requestReadMessages(callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        DispatchQueue.main.async {
            let results = OfflineManager.sharedInstance.readObjects(type: RealmMessageDataModel.self)
            self.arrayMessages = []
            
            for result in results {
                if let realmMessage = result as? RealmMessageDataModel {
                    let message = realmMessage.serializeToDataModel()
                    self.arrayMessages.append(message)
                }
            }
            
            /// Realm doesn't guarantee the read-sequence of objects
            self.sort()
            callback?(NetworkResponseDataModel<Any>.instanceForSuccess())
        }

    }
    
}
