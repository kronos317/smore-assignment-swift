//
//  NetworkManager.swift
//  SMoreTest
//
//  Created by Onseen on 8/6/21.
//

import UIKit
import Alamofire

class NetworkManager: NSObject {
    
    private static func request(method: HTTPMethod, url: URL, params: [String: Any], headers: [String: String], authOptions: Int, encoding: ParameterEncoding, tries: Int, callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        
        let sessionToken = UtilsString.generateRandomString(length: 16)
        UtilsGeneral.log(text: "[NetworkManager - (\(sessionToken))] - \(method.rawValue): " + url.absoluteString)
        UtilsGeneral.log(text: params.description)

        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers).responseJSON { (response) in
            let result = NetworkResponseDataModel<Any>.instanceFromDataResponse(response)
            
            if result.isSuccess() {
                UtilsGeneral.log(text: "[NetworkManager - (\(sessionToken))] - Succeeded")
            }
            else {
                UtilsGeneral.log(text: "[NetworkManager - (\(sessionToken))] - Failed. Reason = " + result.errorMessage)
            }
            
            callback?(result)
        }
    }
    
    public static func GET(endPoint: String, params: [String: String]?, authOptions: Int, callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        
        var urlString = endPoint
        if let params = params {
            urlString.append("?")
            for (key, value) in params {
                if key.count > 0 {
                    let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    urlString.append(key + "=" + escapedValue + "&")
                }
            }
            if urlString.ends(with: "&") {
                urlString = String(urlString.dropLast())
            }
        }
        
        let url = URL.init(string: urlString)
        let header: [String: String] = [:]
        
        NetworkManager.request(method: .get, url: url!, params: [:], headers: header, authOptions: authOptions, encoding: URLEncoding.default, tries: 0, callback: callback)
    }
    
    public static func POST(endPoint: String, params: [String: Any], authOptions: Int, callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        
        let url = URL.init(string: endPoint)
        let header: [String: String] = [:]
        
        NetworkManager.request(method: .post, url: url!, params: params, headers: header, authOptions: authOptions, encoding: JSONEncoding.default, tries: 0, callback: callback)
    }
    
    public static func PUT(endPoint: String, params: [String: Any], authOptions: Int, callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        
        let url = URL.init(string: endPoint)
        let header: [String: String] = [:]
        
        NetworkManager.request(method: .put, url: url!, params: params, headers: header, authOptions: authOptions, encoding: JSONEncoding.default, tries: 0, callback: callback)
    }
    
    public static func UPLOAD(endPoint: String, fileName: String, mimeType: String, file: Data, authOptions: Int, callback: ((NetworkResponseDataModel<Any>) -> ())?) {
        
        let url = URL.init(string: endPoint)
        var header: [String: String] = [:]
        header["Content-Type"] = "multipart/form-data"
        
        let sessionToken = UtilsString.generateRandomString(length: 16)
        UtilsGeneral.log(text: "[NetworkManager - (\(sessionToken))] - UPLOAD FILE: " + endPoint)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(file, withName: "photo",fileName: fileName, mimeType: mimeType)
        }, usingThreshold: UInt64.init(),
           to: url!,
           method: .put,
           headers: header) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let result = NetworkResponseDataModel<Any>.instanceFromDataResponse(response)
                    if result.isSuccess() {
                        UtilsGeneral.log(text: "[NetworkManager - (\(sessionToken))] - Succeeded")
                    }
                    else {
                        UtilsGeneral.log(text: "[NetworkManager - (\(sessionToken))] - Failed. Reason = " + result.errorMessage)
                    }
                    callback?(result)
                }
            case .failure(let encodingError):
                print(encodingError)
                UtilsGeneral.log(text: "[NetworkManager - (\(sessionToken))] - Failed. Reason = " + encodingError.localizedDescription)
                callback?(NetworkResponseDataModel<Any>.instanceForFailure())
            }
        }
    }
    
    public static func DOWNLOAD(endpoint: String, downloadDestination: DownloadRequest.DownloadFileDestination?, callback: ((NetworkResponseDataModel<String>) -> ())?) {
        
        let destination = downloadDestination ?? Alamofire.DownloadRequest.suggestedDownloadDestination()
        let header: [String: String] = [:]

        Alamofire.download(endpoint, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header, to: destination).downloadProgress { (progress) in
            
        }.response { (response) in
            let result = NetworkResponseDataModel<String>()
            if let statusCode = response.response?.statusCode, statusCode == EnumNetworkResponseCode.CODE_200_OK.rawValue {
                result.code = .CODE_200_OK
                result.parsedObject = response.destinationURL?.path ?? ""
            }
            else {
                result.code = .CODE_400_BAD_REQUEST
                result.errorMessage = "Unknown Error"
            }
            callback?(result)
        }
    }
    
}

enum EnumNetworkAuthOptions: Int {

    case AUTH_NONE = 0b00000000
    case AUTH_REQUIRED = 0b00000001

}

enum EnumNetworkRequestMethodType: Int, CaseIterable {
    
    case NONE = 0
    case GET = 1
    case POST = 2
    case PUT = 3
    case DELETE = 4
    case UPLOAD = 5
    case DOWNLOAD = 6
    
    static func fromInt(value: Int) -> EnumNetworkRequestMethodType {
        for method in EnumNetworkRequestMethodType.allCases {
            if method.rawValue == value {
                return method
            }
        }
        return .NONE
    }
    
}
