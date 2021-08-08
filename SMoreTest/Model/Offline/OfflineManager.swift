//
//  OfflineManager.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit
import RealmSwift

class OfflineManager: NSObject {

    public static let sharedInstance = OfflineManager()
    
    fileprivate var realm: Realm!
   
    override init() {
        super.init()
        
        DispatchQueue.main.async {
            Realm.Configuration.defaultConfiguration = Realm.Configuration()
            Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true

            self.realm = try! Realm()
            
            if let path = Realm.Configuration.defaultConfiguration.fileURL?.absoluteString {
                UtilsGeneral.log(text: "[Realm] DB file = " + path)
            }
        }
    }
    
    func initialize() {
    }
    
    // MARK: - Read
    
    func readObject(type: Object.Type, primaryKey: String) -> Object? {
        return realm.object(ofType: type, forPrimaryKey: primaryKey)
    }
    
    func readObject(type: Object.Type) -> Object? {
        return realm.objects(type).first
    }
    
    func readObjects(type: Object.Type) -> Results<Object> {
        return realm.objects(type)
    }
    
    // MARK: - Write
    
    func write(object: Object) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.add(object, update: .modified)
            }
        }
    }
    
    func write(objects: [Object]) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.add(objects, update: .modified)
            }
        }
    }
    
    func deleteAll() {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.deleteAll()
            }
        }
    }
    
    func delete(type: Object.Type) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.delete(self.realm.objects(type))
            }
        }
    }
    
    func delete(type: Object.Type, primaryKey: String) {
        DispatchQueue.main.async {
            try! self.realm.write {
                if let object = self.realm.object(ofType: type, forPrimaryKey: primaryKey) {
                    self.realm.delete(object)
                }
            }
        }
    }
    
    func replaceAll(type: Object.Type, newObjects: [Object]) {
        DispatchQueue.main.async {
            try! self.realm.write {
                self.realm.delete(self.realm.objects(type))
                self.realm.add(newObjects, update: .modified)
            }
        }
    }
    
}

// MARK: - UIImage

extension OfflineManager {
    
    func saveImageToDisk(image: UIImage, path: URL?) -> Bool {
        guard let path = path else {
            return false
        }
        
        var data: Data? = nil
        
        data = image.pngData()
        if data == nil {
            data = image.jpegData(compressionQuality: 1)
        }
        guard let data = data else {
            return false
        }
        
        do {
            UtilsGeneral.log(text: "writing image at ... " + path.absoluteString)
            try data.write(to: path)
            return true
        }
        catch {
            UtilsGeneral.log(text: "writing image failed with error - \(error)")
            return false
        }
    }
    
}

enum EnumOfflineSyncStatus: Int {
    
    case READY = 0
    case IN_PROGRESS = 1
    
}
