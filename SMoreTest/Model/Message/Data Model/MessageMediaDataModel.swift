//
//  MessageMediaDataModel.swift
//  SMoreTest
//
//  Created by Onseen on 8/7/21.
//

import UIKit

class MessageMediaDataModel: NSObject {

    var szFileName: String! = ""
    var imageCache: UIImage? = nil
    
    func initialize() {
        self.szFileName = ""
        self.imageCache = nil
    }
    
    // MARK: - Utils
    
    func getLocalFilePath() -> URL {
        let path = UtilsGeneral.getDocumentsDirectory()
        return path.appendingPathComponent(self.szFileName)
    }
    
    func loadImageFromDisk() -> UIImage? {
        let filepath = self.getLocalFilePath()
        return UIImage(contentsOfFile: filepath.path)
    }
}

enum EnumMediaMimeType: String, CaseIterable {
    
    case NONE = ""
    case PNG = "image/png"
    case JPEG = "image/jpg"
    case PDF = "application/pdf"
    
    static func fromString(_ string: String?) -> EnumMediaMimeType {
        guard let string = string else {
            return .NONE
        }
        
        for t in EnumMediaMimeType.allCases {
            if t.rawValue.caseInsensitiveCompare(string) == .orderedSame {
                return t
            }
        }
        
        return .NONE
    }

}
